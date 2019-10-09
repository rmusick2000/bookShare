#!/usr/bin/env python

import sys
import time
import os
import platform
import logging

from os import path

# from collections import OrderedDict

from threading import Thread
# https://docs.python.org/2/library/subprocess.html
from subprocess import call, check_output, Popen, PIPE

from packaging import version
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

import awsBSCommon


def updateHost():
    logging.info("Trying to update localhost")
    call("sudo apt-get update", shell=True)

# NOTE: thanks to pyenv,
#   1: do not run pips as sudo - else does not update local python version (!!!)
#   2: run all, even if global python is 'updated'.  Local python needs all of this
def InstallAWSPermissions():
    logging.info ("Updating aws requirements, permissions")
    updateHost()
    configLoc = os.environ['HOME']+"/.aws"
    
    # python3, boto3
    # for aws synch
    call( "sudo apt-get install -y ntp", shell=True )
    # Get pip?
    if( call("command -v pip", shell=True) != 0 and call("command -v pip3", shell=True) != 0 ) : 
        call("sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py", shell=True)
        call("python get-pip.py", shell=True )
    
    call("pip install --upgrade pip", shell=True )
    call("pip install paramiko --upgrade", shell=True )
    call("pip install certifi --upgrade", shell=True )
    call("pip install awscli --upgrade", shell=True )
    call("pip install packaging --upgrade", shell=True )
    # urllib3 issues, this is dangerous
    # sudo pip install awscli --upgrade --ignore-installed urllib3
    # call("pip install urllib3 --upgrade", shell=True )
    call("pip install boto3 --upgrade", shell=True )

    call( "sudo rm -rf " + configLoc, shell=True )
    call( "mkdir -p " + configLoc, shell=True )
    call( "cp "+awsBSCommon.bsAuthPath+"config " + configLoc+"/config", shell=True) 
    call( "cp "+awsBSCommon.bsAuthPath+"credentials " + configLoc+"/credentials", shell=True) 

    

def validateConfiguration():
    logging.info("Validating local environment")
    goodConfig = True
    if( platform.system() != 'Linux' ) :
        logging.warning( "You do not appear to be running on a Linux platform.  This code has not be tested on other platforms." )
        goodConfig = False
    if( "Ubuntu" not in platform.version() ) :
        logging.warning( "You do not appear to be running an Ubuntu distribution.  This code has not be tested on other distributions." )
        goodConfig = False
    if( call("command -v sam", shell=True) != 0 ) :
        logging.warning( "AWS SAM CLI does not appear to be installed" )
        goodConfig = False
    if( call("command -v npm", shell=True) != 0 ) :
        logging.warning( "npm does not appear to be installed" )
        goodConfig = False
    if( call("command -v nodejs", shell=True) != 0 ) :
        logging.warning( "nodejs does not appear to be installed" )
        goodConfig = False
    else :
        nver = check_output(["nodejs", "--version"]).decode('utf-8')
        # XXX mv hardcoded val
        if( version.parse( nver ) < version.parse("8.0.0") ) :
            logging.warning( "Please update your nodejs version" )
            goodConfig = False
        
    return goodConfig

def getCFStacks():
    logging.info("Get AWS Cloudformation stacks")    

    # explicitly set region name, even though config file should do the same
    cfn = boto3.resource('cloudformation', region_name = awsBSCommon.bsRegion )
    for stack in cfn.stacks.all() :
        logging.info( stack.stack_name + " " + stack.stack_status + " " +  stack.last_updated_time.strftime("%m/%d/%Y -- %H:%M:%S") )

def cfStackExists( stackName ):
    exists = False

    cfn = boto3.resource('cloudformation', region_name = awsBSCommon.bsRegion )
    for stack in cfn.stacks.all() :
        if( stack.stack_name == stackName ):
            exists = True
            break
            
    return exists
        
def s3CanCreate( bucketName ) :
    s3 = boto3.resource('s3')

    exists = True
    canCreate = False
    status_code = '200' 
    try:
        s3.meta.client.head_bucket( Bucket=bucketName )
    except ClientError as e:
        status_code = e.response['Error']['Code']
        if status_code == '403':  # access denied
            exists = True
            canCreate = False
        if status_code == '404':  # does not exist
            exists = False
            canCreate = True

    assert( not ( canCreate and exists ))
    return exists, canCreate, status_code
    
        
def makeDeployBucket():
    logging.info("Make deploy bucket" )

    bucketName = awsBSCommon.samDeployBucket
    
    exists, canCreate, status_code = s3CanCreate( bucketName )

    if( exists and status_code != '403' ):
        logging.info( bucketName + " already exists, no action taken." )
    elif( status_code == '403' ) :
        logging.info( bucketName + " already exists, access is forbidden.  Please choose another name. ")        
    elif( canCreate ) :
        logging.info( bucketName + " does not exist, creating.." )
        # aws s3 mb s3://aname.samm.deploy --region us-east-1
        s3 = boto3.resource('s3')
        # Strange, old bug in boto3 s3 api...
        if( awsBSCommon.bsRegion == 'us-east-1' ) :
            s3.create_bucket(Bucket=bucketName )
        else :
            s3.create_bucket(Bucket=bucketName, CreateBucketConfiguration={'LocationConstraint': awsBSCommon.bsRegion })


def runSAMTemplate( template, deployBucket, stackName ) :
    logging.info( "Running SAM template: " + template )

    # create the "Pack"aged string 
    templPack = template
    assert( len(templPack) > 5 )
    assert( templPack[-4:] == "yaml" )
    templPack = templPack[0:-5] + "Pack.yaml"
    
    if( not path.exists( template ) ) :
        logging.error( "Yaml template " + template + " does not exist." )
        return

    if( cfStackExists( stackName ) ):
        logging.warning( "Cloudformation stack " + stackName + " already exists.  No action taken." )
        return
    
    try: 
        cmd = "sam validate -t " + template
        logging.info( cmd )
        val = check_output(cmd, shell=True).decode('utf-8')    
        logging.info( val )
    except ClientError as e:
        logging.error( e )

    try: 
        cmd = "sam build -t " + template
        logging.info( cmd )
        val = check_output(cmd, shell=True).decode('utf-8')    
        logging.info( val )
    except ClientError as e:
        logging.error( e )

    try: 
        cmd  = "sam package --template-file " + template + " --output-template " + templPack
        cmd += " --s3-bucket " + deployBucket
        logging.info( cmd )
        val = check_output(cmd, shell=True).decode('utf-8')    
        logging.info( val )
    except ClientError as e:
        logging.error( e )

    try: 
        cmd =  "sam deploy --template-file " + templPack + " --region " + awsBSCommon.bsRegion
        cmd += " --capabilities CAPABILITY_IAM --stack-name " + stackName
        logging.info( cmd )
        logging.info( "This may take a few minutes...." )
        val = check_output(cmd, shell=True).decode('utf-8')    
        logging.info( val )
    except ClientError as e:
        logging.error( e )


def createStaticWebBucket() :
    bucketName =  awsBSCommon.samStaticWebBucket 
    logging.info( "Creating S3 static web bucket " + bucketName)

    # Check deploy bucket
    exists, canCreate, status_code = s3CanCreate( awsBSCommon.samDeployBucket )
    if( not exists or status_code == '403' ) :
        logging.info(  "Please create the SAM deployment bucket first." )
        return

    # Run template if static web bucket can be created
    exists, canCreate, status_code = s3CanCreate( bucketName )
    if( exists and status_code != '403' ):
        logging.info( bucketName + " already exists, no action taken." )
    elif( status_code == '403' ) :
        logging.info( bucketName + " already exists, access is forbidden.  Please choose another name. ")        
    elif( canCreate ) :
        runSAMTemplate( template = awsBSCommon.samStaticWebYAML, deployBucket = awsBSCommon.samDeployBucket, stackName = awsBSCommon.samStaticWebStackName )

def createServerlessInfrastructure() :
    webBucket =  awsBSCommon.samStaticWebBucket 
    logging.info( "Creating Serverless Infrastructure for BookShare" )

    # Check deploy bucket
    exists, canCreate, status_code = s3CanCreate( awsBSCommon.samDeployBucket )
    if( not exists or status_code == '403' ) :
        logging.info(  "Please create the SAM deployment bucket first." )
        return

    # Run template
    runSAMTemplate( template = awsBSCommon.samInfrastructureYAML, deployBucket = awsBSCommon.samDeployBucket, stackName = awsBSCommon.samBookShareAppStackName )

def removeStackResources( cfStackName ) :
    if( not cfStackExists( cfStackName ) ) :
        logging.warning( cfStackName + " does not exist.  No need to delete it." )
        return

    client = boto3.client('cloudformation', region_name = awsBSCommon.bsRegion )

    # delete all s3 bucket contents first, to allow removal of bucket
    stackResourceSummaries = client.list_stack_resources( StackName = cfStackName )
    for resource in stackResourceSummaries['StackResourceSummaries'] :
        print( resource['LogicalResourceId'], resource['PhysicalResourceId'], resource['ResourceType'] )
        if( resource['ResourceType'] == "AWS::S3::Bucket" ) :
            # cmd = "aws s3 rb s3://bookshare.codeequity.net --force"
            s3 = boto3.resource('s3')
            bucket = s3.Bucket( resource['PhysicalResourceId'] )
            bucket.objects.delete()
                
            # done?
            for obj in bucket.objects.all() :
                logging.error( "Bucket delete did not complete" )
                assert( False )

    # aws cloudformation delete-stack --stack-name S3StaticWeb
    client.delete_stack( StackName = cfStackName )

    seconds = 0
    while( cfStackExists( cfStackName ) ) :
        status = client.describe_stacks( StackName = cfStackName )['Stacks'][0]['StackStatus']
        if( status == "DELETE_IN_PROGRESS" and seconds % 5 == 0 ) :
            logging.info( cfStackName + " " + status + " time elapsed: " + str(seconds)  )

        if( not status == "DELETE_IN_PROGRESS" or seconds >= 120 ) :
            logging.error( cfStackName + " stack was not deleted. Perhaps it is in use by other cloudFormation stacks? " )
            logging.error( "Time spent: " + str(seconds) + " status: " + status )
            break
        time.sleep(1)
        seconds += 1
        

# XXX remove deployment bucket
def deleteAWSRes() :
    logging.info( "Removing CloudFormation stacks and resources" )
    logging.info("")
    logging.info("BookShare app stack")
    removeStackResources( awsBSCommon.samBookShareAppStackName )
    logging.info("")
    logging.info("S3 stack")
    removeStackResources( awsBSCommon.samStaticWebStackName )




    
"""

stacks = conn.describe_stacks('MyStackID')
if len(stacks) == 1:
    stack = stacks[0]
else:
    # Raise an exception or something because your stack isn't there

for output in stack.outputs:
    print('%s=%s (%s)' % (output.key, output.value, output.description))

"""
        
# XXX Class me

def main( cmd ):
    #print locals()
    #print globals()
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p', 
                        handlers= [logging.FileHandler(filename='bookShare.log'),logging.StreamHandler()],
                        level=logging.INFO)

    assert( validateConfiguration() )

    if( cmd == "" ) :
        getCFStacks()
        makeDeployBucket()
        createStaticWebBucket()
        createServerlessInfrastructure()
    

    logging.info("add static pages, css, etc.  flutter? ")
    logging.info("Connect static web to infrastructure")

    logging.info("Separate Cognito auth")

    logging.info("Remove AWS Resources")

    logging.info("Run basic stress test")
    logging.info("Get insights AWS")
    logging.info("Get insights Github")

    if( cmd == "validateConfiguration" or cmd == "") :
        logging.info( "finished...exiting" )
        return 
    
    thread = Thread( target=globals()[cmd]() )
    thread.start()
    thread.join()
    logging.info( "thread finished...exiting" )

    
if __name__ == "__main__":
    awsBSCommon.init()   
    
    # print locals()   
    # print sys.argv
    if len(sys.argv) < 2:
        main("")
        #raise SyntaxError("Insufficient arguments.")
    else:
        main(sys.argv[1])

