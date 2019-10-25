import os

def init():
    global bsRegion
    global bsAuthPath
    global bsSharedPem
    global bsProvPath
    global bsAppPath
    global bsNodeJSVersion
    global bsAppConfigPath  # android assets for cognito plugin
    global bsAppConfigName
    global bsAppAssetPath   # more typical pubspec.yaml assets
    global access_key_id
    global secret_access_key
    
    global samDeployBucket
    global samStaticWebBucket
    global samStaticWebYAML
    global samInfrastructureYAML
    global samStaticWebStackName
    global samBookShareAppStackName
    
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

    bsAuthPath      = os.environ['BSPATH']+"/ops/awsAuth/"
    bsSharedPem     = bsAuthPath+"awsKey.pem"
    bsProvPath      = os.environ['BSPATH']+"/ops/awsUtils/"
    bsAppPath       = os.environ['BSPATH']+"/bookShareApp/"
    bsNodeJSVersion = "8.0.0"
    bsAppConfigPath = bsAppPath + "book_flutter/android/app/src/main/res/raw/"
    bsAppConfigName = "awsconfiguration.json"
    bsAppAssetPath  = bsAppPath + "book_flutter/files/"
    
    samDeployBucket        = "bookshare.sam.deploy"
    samStaticWebBucket     = "bookshare.codeequity.net"   # note this has to be consistent with yaml
    samStaticWebYAML       = os.environ['BSPATH']+"/bookShareApp/samStaticWeb.yaml"
    samInfrastructureYAML  = os.environ['BSPATH']+"/bookShareApp/samInfrastructure.yaml"

    samStaticWebStackName       = "bookShareS3"
    samBookShareAppStackName    = "bookShareApp"
