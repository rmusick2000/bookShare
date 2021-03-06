#!/usr/bin/env python

import sys
import os
import platform
import logging

import json    #test data import
import boto3   #test data import

from os import path

from threading import Thread
from subprocess import call, check_output, Popen, PIPE

from packaging import version

from samInstance import samInstance
import awsBSCommon

# XXX create, delete awsConfig for bookFlutter, when create/delete BS resources
# XXX later, something like https://aws.amazon.com/blogs/architecture/new-application-integration-with-aws-cloud-map-for-service-discovery/
# XXX Add jq to setup script.  (sudo apt install jq)

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
        if( version.parse( nver ) < version.parse(awsBSCommon.bsNodeJSVersion) ) :
            logging.warning( "Please update your nodejs version" )
            goodConfig = False
        
    return goodConfig



def getCFStacks( sam ) :
    sam.getStacks()


# Get size of table: aws dynamodb describe-table --table-name Libraries
# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Backup.Tutorial.html


#def getDynamoData( sam ) :
    #cmd = "aws dynamodb scan --table-name Books | jq '{"Books": [.Items[] | {PutRequest: {Item: .}}]}' > testData/testDataBooks.json"
    #cmd = "aws dynamodb scan --table-name Ownerships | jq '{"Ownerships": [.Items[] | {PutRequest: {Item: .}}]}' > testData/testDataOwnerships.json"
    #cmd = "aws dynamodb scan --table-name Libraries | jq '{"Libraries": [.Items[] | {PutRequest: {Item: .}}]}' > testData/testDataLibraries.json"
    #cmd = "aws dynamodb scan --table-name People | jq '{"People": [.Items[] | {PutRequest: {Item: .}}]}' > testData/testDataPeople.json"
    

def splitAndLoad( sam, fileName, tableName ) :
    d={}
    with open( fileName ) as f:
        d = json.load(f)

    client = boto3.client('dynamodb')

    for x in sam.batchRip( d[tableName], 25 ):
        subbatch_dict = {tableName: x}
        response = client.batch_write_item(RequestItems=subbatch_dict)

    
# CAREFUL (!!!) this writes to dynamo
def createTestDDBEntries( sam ) :
    # cmd = "aws dynamodb batch-write-item --request-items file://testData/testDataOwnerships.json"
    splitAndLoad(sam, "testData/testDataPeople.json", "People" )
    splitAndLoad(sam, "testData/testDataLibraries.json", "Libraries" )
    splitAndLoad(sam, "testData/testDataBooks.json", "Books" )
    splitAndLoad(sam, "testData/testDataOwnerships.json", "Ownerships" )

    
def createConfigFiles( sam, Xs = False ):
    poolID   = "us-east-1_XXXXXXXXX"
    clientID = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    apiBase  = "https://XXXXXXXXXX.execute-api.us-east-1.amazonaws.com/XXXX"

    if( not Xs ) :
        poolID   = sam.getStackOutput( awsBSCommon.samBookShareAppStackName, "UserPoolID" )
        clientID = sam.getStackOutput( awsBSCommon.samBookShareAppStackName, "UserPoolClientId" )
        apiBase  = sam.getStackOutput( awsBSCommon.samBookShareAppStackName, "BookShareApiExecution" )

    configData = "{\n"
    configData += "    \"CognitoUserPool\": {\n"
    configData += "        \"Default\": {\n"
    configData += "            \"PoolId\": \"" + poolID + "\",\n"
    configData += "            \"AppClientId\": \"" + clientID + "\",\n"
    configData += "            \"AppClientSecret\": \"\",\n"
    configData += "            \"Region\": \"" + awsBSCommon.bsRegion + "\"\n"
    configData += "        }\n"
    configData += "    }\n"
    configData += "}\n\n"
    
    filenameConfig = awsBSCommon.bsAppConfigPath + awsBSCommon.bsAppConfigName
    with open(filenameConfig, "w+") as f:
        f.write(configData)

    filenamePath = awsBSCommon.bsAppAssetPath + "api_base_path.txt"
    with open(filenamePath, "w+") as f:
        f.write(apiBase)

    # push to S3 bucket to allow deployed apps to reach new backend Cognito
    # unfortunately, flutter_cognito plugin bakes this info in at deploy time - no way to update
    """
    if( not Xs ) :
        s3Name = "s3://" + awsBSCommon.samStaticWebBucket + "/"
        cmd1 = "aws s3 cp " + filenameConfig + " " + s3Name + filenameConfig
        cmd2 = "aws s3 cp " + filenamePath   + " " + s3Name + filenamePath
        if( call(cmd1,  shell=True) != 0 ) : logging.warning( "Failed to create config file on S3" )
        if( call(cmd2,  shell=True) != 0 ) : logging.warning( "Failed to create apiBase file on S3" )
    """

    # instead, write configData to files as well - xplatform.  Could get from awsconfig, but that is Android-specific
    filenameConfig = awsBSCommon.bsAppAssetPath + awsBSCommon.bsAppConfigName
    with open(filenameConfig, "w+") as f:
        f.write(configData)
    
    
    
def anonymizeConfigFiles( sam ):
    createConfigFiles( sam, Xs = True )


        
def makeBSResources( sam ) :
    #Make a SAM deployment bucket, create another S3 bucket for static pages, then create the infrastructure
    sam.makeDeployBucket( awsBSCommon.samDeployBucket )

    sam.createS3Bucket( stackName    = awsBSCommon.samStaticWebStackName, 
                        template     = awsBSCommon.samStaticWebYAML, 
                        bucketName   = awsBSCommon.samStaticWebBucket, 
                        deployBucket = awsBSCommon.samDeployBucket )

    sam.createServerlessInfrastructure( stackName    = awsBSCommon.samBookShareAppStackName, 
                                        template     = awsBSCommon.samInfrastructureYAML,
                                        webBucket    = awsBSCommon.samStaticWebBucket, 
                                        deployBucket = awsBSCommon.samDeployBucket )

    # XXX Until we have dynamic resource configuration, create local BS config files
    createConfigFiles( sam )
    createTestAccounts( sam )
    createTestDDBEntries( sam )

    
def createTestAccounts( sam ) :
    #Create and confirm all _bs_tester accounts
    poolID   = sam.getStackOutput( awsBSCommon.samBookShareAppStackName, "UserPoolID" )
    cmdBase = "aws cognito-idp admin-create-user --message-action SUPPRESS --user-pool-id " + poolID + " --username "
    pwdBase = "aws cognito-idp admin-set-user-password --user-pool-id " + poolID + " --username "
    unameBase = "_bs_tester_1664"

    # Test login switchboard, does very little work
    tbase  = cmdBase + unameBase + " --user-attributes Name=email,Value=success@simulator.amazonses.com Name=email_verified,Value=true"
    tpBase = pwdBase + unameBase + " --password passWD123 --permanent"
    if( call(tbase,  shell=True) != 0 ) : logging.warning( "Failed to create tester " )
    if( call(tpBase, shell=True) != 0 ) : logging.warning( "Failed set password " )

    # Actual test accounts that do all the work
    username = ""
    for i in range(10):
        username = unameBase + "_" + str(i)
        tbase  = cmdBase + username + " --user-attributes Name=email,Value=success@simulator.amazonses.com Name=email_verified,Value=true"
        tpBase = pwdBase + username + " --password passWD123 --permanent"
        if( call(tbase,  shell=True) != 0 ) : logging.warning( "Failed to create tester " )
        if( call(tpBase, shell=True) != 0 ) : logging.warning( "Failed set password " )

    # Add aspell and dbase accounts for by-hand testing
    tbase  = cmdBase + "dbase --user-attributes Name=email,Value=success@simulator.amazonses.com Name=email_verified,Value=true"
    tpBase = pwdBase + "dbase --password passWD123 --permanent"
    if( call(tbase,  shell=True) != 0 ) : logging.warning( "Failed to create tester " )
    if( call(tpBase, shell=True) != 0 ) : logging.warning( "Failed set password " )

    tbase  = cmdBase + "aspell --user-attributes Name=email,Value=success@simulator.amazonses.com Name=email_verified,Value=true"
    tpBase = pwdBase + "aspell --password passWD123 --permanent"
    if( call(tbase,  shell=True) != 0 ) : logging.warning( "Failed to create tester " )
    if( call(tpBase, shell=True) != 0 ) : logging.warning( "Failed set password " )

    # Create corresponding entries in library and person tables.
    cmd = "aws dynamodb batch-write-item --request-items file://testData/testDataPeople.json"
    if( call(cmd, shell=True) != 0 ) : logging.warning( "Failed to write test data: People " )
    
    cmd = "aws dynamodb batch-write-item --request-items file://testData/testDataLibraries.json"
    if( call(cmd, shell=True) != 0 ) : logging.warning( "Failed to write test data: Libraries " )



def help() :
    logging.info( "Available commands:" )
    logging.info( "  - makeBSResources:       create all required BookShare resources on AWS." )
    logging.info( "  - deleteBSResources:     remove all BookShare resources on AWS." )
    logging.info( "  - getCFStacks:           list your AWS CloudFormation stacks." )
    logging.info( "  - getStackOutputs:       display the outputs of BookShare's AWS CloudFormation stacks." )
    logging.info( "  - validateConfiguration: Will assert if your dev environment doesn't look suitable." )
    logging.info( "  - createTestDDBEntries:  Adds some test data to AWS DynamoDB tables")
    logging.info( "  - createTestAccounts:    Adds _bs_tester accounts and signup data for integration testing.")
    logging.info( "  - help:                  list available commands." )
    logging.info( "" )
    logging.info( "Alpha-level commands:" )
    logging.info( "  - InstallAWSPermissions: Attempts to create a valid dev environment.  Best used as a set of hints for now." )


# XXX remove deployment bucket? option to keep buckets around, so names not lost?
def deleteBSResources( sam ) :
    logging.info("")
    logging.info("Remove BookShare app stack")
    sam.removeStackResources( awsBSCommon.samBookShareAppStackName )
    logging.info("")
    logging.info("Remove S3 stack")
    sam.removeStackResources( awsBSCommon.samStaticWebStackName )

    # XXX Until we have dynamic resource configuration, delete local BS config files
    anonymizeConfigFiles( sam )
    

def getStackOutputs( sam ) :
    sam.describeStack( awsBSCommon.samBookShareAppStackName )
    sam.describeStack( awsBSCommon.samStaticWebStackName )


    
def main( cmd ):
    #print locals()
    #print globals()
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p', 
                        handlers= [logging.FileHandler(filename='bookShare.log'),logging.StreamHandler()],
                        level=logging.INFO)

    assert( validateConfiguration() )

    sam = samInstance( region = awsBSCommon.bsRegion )

    logging.info("")
    logging.info("TODO:")
    logging.info("Run stress tests")
    logging.info("Get insights AWS")
    logging.info( "END TODO")
    logging.info("")
    
    if( cmd == "validateConfiguration") :
        logging.info( "finished...exiting" )
        return 

    if( cmd == "help" or cmd == "") :
        help()
        return

    thread = Thread( target=globals()[cmd]( sam ) )
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

