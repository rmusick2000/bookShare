BookShare is an easy to use app for organizing a private library
between a small group of people.  With BookShare, you can add your own
contributions to a library by scanning it with your phone.  You can
also locate and request books in the library that currently reside
with other members.

For example, a bookclub can use BookShare to keep track of who
currently has which books on the reading list for the summer.

For example, an extended family can share all the Warriors books
between the cousins.

For example, a language school typically has a very interested, active
community of families, together with a rich but inaccessible trove of
foreign language books.  Bookshare unlocks that treasure for the
language school by making it easy to share and track any book that a
participating member is willing to loan out to the community.

BookShare works best with book archiving apps, such as "My Library".


NOTE: Set environment variable BSPATH to this github project directory.


STATUS 10/23/19:
 * AWS infrastructure creation in createBS.py is in reasonable shape.
   Python script runs AWS SAM and Cloudformation templates and
   commands through boto3 and the command line interface.
   Infrastucture includes: 
   - S3 deployment bucket
   - S3 bucket set up for static web site
   - Cognito user pool authentication
   - API + Lambda stub using dynamo
   - DynamoDB
   - Cloudwatch
   - all necessary IAM roles

  CreateBS.py requires a functional boto/awscli/awssam environment as
  detailed here: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html
  The script includes functionality to set this up for a Linux build,
  but it is not well-tested.

 * Bookshare App:  EARLY STAGES, work in progress.

 * App development:  Flutter, on Android emulator for Nexus IV
   with API 27.


