#!/usr/bin/env python

import sys
import os
import platform
import logging

from os import path

from threading import Thread
from subprocess import call, check_output, Popen, PIPE

from packaging import version

from samInstance import samInstance
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



def getCFStacks( sam ) :
    sam.getStacks()

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


def help() :
    logging.info( "Available commands:" )
    logging.info( "  - makeBSResources:       create all required BookShare resources on AWS." )
    logging.info( "  - deleteBSResources:     remove all BookShare resources on AWS." )
    logging.info( "  - getCFStacks:           list your AWS CloudFormation stacks." )
    logging.info( "  - getStackOutputs:       display the outputs of BookShare's AWS CloudFormation stacks." )
    logging.info( "  - validateConfiguration: Will assert if your dev environment doesn't look suitable." )
    logging.info( "  - help:                  list available commands." )
    logging.info( "" )
    logging.info( "Alpha-level commands:" )
    logging.info( "  - InstallAWSPermissions: Attempts to create a valid dev environment.  Best used as a set of hints for now." )


def deleteBSResources( sam ) :
    logging.info("")
    logging.info("Remove BookShare app stack")
    sam.removeStackResources( awsBSCommon.samBookShareAppStackName )
    logging.info("")
    logging.info("Remove S3 stack")
    sam.removeStackResources( awsBSCommon.samStaticWebStackName )
    # XXX remove deployment bucket
    # XXX option to keep buckets around, so names not lost

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
    logging.info("Separate Cognito auth in yamls?")
    logging.info("Run stress tests")
    logging.info("Get insights AWS")
    logging.info("Get insights Github")
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

