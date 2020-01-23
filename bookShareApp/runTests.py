#!/usr/bin/env python

import sys
import os
import platform
import logging
import time

from os import path
from subprocess import call, check_output, Popen, PIPE

#from threading import Thread
#import concurrent.futures


def validateConfiguration():
    logging.info("Validating local environment")
    goodConfig = True
    if( platform.system() != 'Linux' ) :
        logging.warning( "You do not appear to be running on a Linux platform.  This code has not be tested on other platforms." )
        goodConfig = False
    if( "Ubuntu" not in platform.version() ) :
        logging.warning( "You do not appear to be running an Ubuntu distribution.  This code has not be tested on other distributions." )
        goodConfig = False
    if( call("command -v flutter", shell=True) != 0 ) :
        logging.warning( "Flutter does not appear to be installed" )
        goodConfig = False
        
    return goodConfig


def verifyEmulator():
    logging.info( "Ensure emulator is running" )
    goodConfig = True
    if( call("flutter devices | grep emulator-5554", shell=True) != 0 ) :
        call( "flutter emulators --launch Nexus_4_API_27", shell=True )
        # XXX Can we detect when this is ready?
        # XXX Can auto-wipe user data?
        time.sleep(25)
        if( call("flutter devices | grep emulator-5554", shell=True) != 0 ) :
            goodConfig = False

            
    return goodConfig


def collect( fname ):

    resultsSum = ""
    resultsBulk = ""
    
    f = open( fname, "r" )
    lines = f.readlines()
    for fl in lines :
        if( "I/flutter" in fl ) : continue
        #if( "I/flutter" in fl ) : resultsBulk += fl
        elif( "BookShare Test Group" in fl or
              "tests passed!" in fl        or
              "tests failed!" in fl           ) :
            resultsSum += fl
        resultsBulk += fl

    return resultsBulk, resultsSum


def runTest( testName, noBuild = True ):
    logging.info( "" )
    logging.info( "Running " + testName + " file..." );
    fileName = 'rawTestOutput.txt'

    cmd = "flutter drive "
    # NOTE this causes consequtive runs of flutter driver to connect to the same app, same state(!)
    # cmd += "--no-build" if noBuild else ""
    cmd += " --target=test_driver/" + testName + " > " + fileName;
    os.system( cmd )
    
    tmpBulk, tmpSum = collect( fileName )
    logging.info( "Local results: " )
    logging.info( tmpBulk )
    return tmpBulk, tmpSum


def runTests():

    os.chdir( "./book_flutter" )

    filename = 'rawTestOutput.txt'
    resultsBulk = "" 
    resultsSum = ""


    tbulk, tsum = runTest( "content.dart", False )
    resultsBulk += tbulk
    resultsSum  += tsum

    """
    #tbulk, tsum = runTest( "sharing.dart", False )
    #resultsBulk += tbulk
    #resultsSum  += tsum

    tbulk, tsum = runTest( "login_pass.dart", False )
    resultsBulk += tbulk
    resultsSum  += tsum
    
    tbulk, tsum = runTest( "login_fail.dart", False )
    resultsBulk += tbulk
    resultsSum  += tsum
    """

    
    logging.info( "" );
    logging.info( "================================" );
    logging.info( "Bulk output:" );
    logging.info( "================================" );
    logging.info( resultsBulk );
    logging.info( "" );
    logging.info( "" );
    logging.info( "================================" );
    logging.info( "Summary:" );
    logging.info( "================================" );
    logging.info( resultsSum );
    os.chdir( "../" )


def main( cmd ):
    #print locals()
    #print globals()
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p', 
                        handlers= [logging.FileHandler(filename='bsTests.log'),logging.StreamHandler()],
                        level=logging.INFO)

    assert( validateConfiguration() )
    assert( verifyEmulator() )

    if( cmd == "" ) : runTests()
    else :
        thread = Thread( target=globals()[cmd]( ) )
        thread.start()
        thread.join()
        logging.info( "thread finished...exiting" )

    
    
if __name__ == "__main__":
    # print locals()   
    # print sys.argv
    if len(sys.argv) < 2:
        main("")
        #raise SyntaxError("Insufficient arguments.")
    else:
        main(sys.argv[1])

