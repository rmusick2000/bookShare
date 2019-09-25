#!/usr/bin/env python

# XXX Need bookShare version of awsCommon
# XXX Does this provisioning get shared to Git?  yes.  Need directions for auth generation.
# XXX gitignore files in awsAuth
# XXX awsCommon is a good name within a local context.  pyenv, python search path?

import sys
import time
import os
import logging

from threading import Thread
# from collections import OrderedDict

# https://docs.python.org/2/library/subprocess.html
from subprocess import call

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

    
def main( cmd ):
    #print locals()
    #print globals()
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p', 
                        handlers= [logging.FileHandler(filename='bookShare.log'),logging.StreamHandler()],
                        level=logging.INFO)

    # XXX Allow each to be separately called
    # XXX Set up like a makefile, almost..  Create calls x,y,z.  Destroy calls a.  Report calls e,f,g.
    logging.info("Validate configuration")  # check for SAM, boto3, nodejs, npm, etc
    logging.info("Get AWS stacks")
    logging.info("Read parameters")         # names for AWS resources
    logging.info("Check SAM Deploy Bucket")
    logging.info("Create S3 static web")
    logging.info("Create Cognito auth")
    logging.info("Create Serverless Fwk")
    logging.info("Remove AWS Resources")
    logging.info("Run basic stress test")
    logging.info("Get insights AWS")
    logging.info("Get insights Github")

    thread = Thread( target=globals()[cmd]() )
    thread.start()
    thread.join()
    logging.info( "thread finished...exiting" )

    
if __name__ == "__main__":
    awsBSCommon.init()   
    
    # print locals()   
    # print sys.argv
    if len(sys.argv) < 2:
        raise SyntaxError("Insufficient arguments.")

    main(sys.argv[1])

