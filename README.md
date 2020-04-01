# BookShare Project

The BookShare project helps create and run small private libraries
shared between small groups of people.  BookShare is composed of three
major elements:

 * a flutter-based mobile app, or **BookShare App**; 
 * a serverless AWS backend, or **BookShare Backend**; and
 * a shared equity model for contributors, or **CodeEquity for BookShare**.

# BookShare App

BookShare helps organize private libraries between a small group of
people.  With BookShare, you add your own contributions to a library
by scanning the book's barcode with your phone.  You can join
libraries of people you know.  You can also locate and request books
in your libraries that currently reside with other members.

For example, a bookclub can use BookShare to keep track of who
currently has which books on the reading list for the summer.

For example, an extended family can share all the Warriors books
between the cousins.

For example, a language school may have a very interested, active
community of families, together with a rich but inaccessible trove of
foreign language books.  Bookshare makes it easy to share and track
any book that a participating member is willing to loan out to the
community.

The following gif shows screens including: home; scan a book; refine
search and choose; check details; share book with a member library;
visit a non-member library.

<p float="left">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
  <img src="doc/images/bookshare.gif" width="360" height="600"  />
</p>

<br>


# BookShare Backend

The BookShare backend is a _serverless_ architecture on AWS.  The
architecture is specified with a [yaml
file](bookShareApp/samInfrastructure.yaml) that is a mixture of AWS's
SAM and CloudFormation specifications.  The following diagram is an
overview of the major components in the backend, and how they interact.

<p float="left">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
  <img src="doc/images/bookshare_backend.png" />
</p>

<br>

# CodeEquity for BookShare

Details coming soon!


# Developer Quickstart

1. Create or destroy the BookShare Backend infrascture with
[createBS.py](bookShareApp/createBS.py), for example:
* `python createBS.py help`
* `python createBS.py makeBSResources`

Backend development requires setting the BSPATH evironment variable to
the root of this repository.  For example, in your .bashrc, `export
BSPATH=$CODEPATH/src/bookShare`.

NOTE: a related known issue: AWS S3 bucket names are unique per
region.  S3 bucket names should be parameterized.  Your bucket names
should be set and used in 
[awsBSCommon.py](ops/awsUtils/awsBSCommon.py) and [samStaticWeb.yaml](bookShareApp/samStaticWeb.yaml).

2. Carry out integration testing with
[runTests.py](bookShareApp/runTests.py), for example:
* `python runTests.py`

runTests.py carries out several minutes of integration testing using the Android emulator for
Nexus IV with API 27.

3. Main development components for both the app and the backend include: 
* flutter, master channel  v1.16+
* android studio, v3.6+
* javascript, for AWS lambda 
* python 3.6.7+
* aws development environment with boto/awscli/awssam as detailed
here: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html


# Known Issues

Visit the Issue page in this repository for known issues and feature requests.


# Status 3/30/20

### BookShare App Status

 Content milestone has been reached.  All features related to 
 libraries and books are implemented and tested.

 No sharing-related features have been implemented.  IOS version is
 untouched.  No profile or settings work has been done.

### BookShare Backend Status

 AWS infrastructure creation with createBS.py runs AWS SAM and
 Cloudformation templates through boto3 and the AWS CLI.  

 This is in reasonable shape, with two exceptions: cloud resource
 discovery, and the parameterization of S3 names (see known issues).

### CodeEquity for BookShare Status

 In progress.


# Contributing

See the [CONTRIBUTING](CONTRIBUTING.md) file for how to contribute.

# License

See the [LICENSE](LICENSE) file for our project's licensing.

Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 


