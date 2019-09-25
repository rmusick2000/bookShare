import os

def init():
    global bsRegion
    global bsAuthPath
    global bsSharedPem
    global bsProvPath
    global access_key_id
    global secret_access_key

    try:
        import configparser
        
        configFile = os.path.join(os.environ["HOME"], ".aws", "config") 
        print( "Reading AWS Config:", configFile )
        config = configparser.ConfigParser()
        config.read(configFile)
        access_key_id = config.get('default', 'aws_access_key_id', fallback='NOTHERE')
        secret_access_key = config.get('default', 'aws_secret_access_key', fallback='NOTHERE')
        bsRegion = config.get('default', 'region')

        # credential file may instead hold magic juice
        if( access_key_id == "NOTHERE" ):
            configFile = os.path.join(os.environ["HOME"], ".aws", "credentials") 
            print( "Reading AWS Credentials:", configFile )
            config = configparser.ConfigParser()
            config.read(configFile)
            access_key_id = config.get('default', 'aws_access_key_id')
            secret_access_key = config.get('default', 'aws_secret_access_key')

        print( bsRegion, access_key_id )
    except:
        print( configFile, "missing or invalid" )
        print( "Try running:  python createBS.py 'InstallAWSPermissions()' " )
        #raise

    bsAuthPath     = os.environ['BSPATH']+"/ops/awsAuth/"
    bsSharedPem    = bsAuthPath+"awsKey.pem"
    bsProvPath     = os.environ['BSPATH']+"/ops/awsUtils/"
