// BookShare

const AWS = require('aws-sdk');
const bsdb = new AWS.DynamoDB.DocumentClient();
const randomBytes = require('crypto').randomBytes;

// Because we're using a Cognito User Pools authorizer, all of the claims
// included in the authentication token are provided in the request context.
// This includes the username as well as other attributes.
// The body field of the event in a proxy integration is a raw string.
// In order to extract meaningful values, we need to first parse this string
// into an object. A more robust implementation might inspect the Content-Type
// header first and use a different parsing strategy based on that value.
exports.handler = (event, context, callback) => {

    console.log( 'BookShare Handler start' );
    
    if (!event.requestContext.authorizer) {
	callback( null, errorResponse("401", 'Authorization not configured, dude', context.awsRequestId));
	return;
    }
    
    console.log('Received event: ', event);

    const username = event.requestContext.authorizer.claims['cognito:username'];
    const requestBody = JSON.parse(event.body);

    var endPoint = requestBody.Endpoint;
    var resultPromise;

    if(      endPoint == "FindBook" ) { resultPromise = findBook( requestBody.Title, username ); }
    else if( endPoint == "GetLibs")   { resultPromise = getLibs( username ); }
    else {
	callback( null, errorResponse( "500", "EndPoint request not understood", context.awsRequestId));
	return;
    }

    resultPromise.then((result) => {
	console.log( 'Result: ', result ); 
	callback( null, result );
    }).catch((err) => {
        console.error(err);
        callback( null, errorResponse(err.statusCode, err.message, context.awsRequestId));
    });

};

function getLibs( username ) {
    var assert = require('assert');
    console.log('Get Libs! ' + username );

    // Params to get PersonID from UserName
    const paramsP = {
        TableName: 'People',
        FilterExpression: 'UserName = :uname',
        ExpressionAttributeValues: { ":uname": username }
    };

    
    // Get PersonId

    let personPromise = bsdb.scan( paramsP ).promise();
    return personPromise.then((persons) => {
	console.log( "Persons: ", persons );
	assert(persons.Count == 1 );
	// XXX get item 0 only
	let person = {};
	persons.Items.forEach(function (element) {
	    console.log( "Element: ", element );  
	    person = element;
	});
	console.log( "Found person ", person );
	return person.PersonId;
    }).then((personId) => {

	// Get Libraries

	// Params to get Libraries that have PersonID in Members
	const paramsL = {
            TableName: 'Libraries',
            FilterExpression: 'contains(Members, :pid)',
            ExpressionAttributeValues: { ":pid": personId }
	};
	
	console.log( "Working with ", personId );
	let librariesPromise = bsdb.scan( paramsL ).promise();
	return librariesPromise.then((libraries) => {
	    
	    assert(libraries.Count >= 1 );
	    console.log( "Result: ", libraries );
	    return {
		statusCode: 201,
		body: JSON.stringify( libraries.Items ),
		headers: { 'Access-Control-Allow-Origin': '*' }
	    };
	});
    });

    /*
    return new Promise((resolve, reject) => {
	resolve(  {
        statusCode: 201,
        body: JSON.stringify([{
            id: 3,
            name: "MoJo Moomin",
	    imageID: 234
        }]),
        headers: {
            'Access-Control-Allow-Origin': '*',
        }});
    });
    */
}


function findBook(bookTitle, username) {
    console.log('Finding book for ', bookTitle ); 

    const bookId = toUrlString(randomBytes(16));

    // Title must be :bookTitle, where :bookTitle = bookTitle.  grack.
    const params = {
        TableName: 'Books',
        FilterExpression: 'Title = :bookTitle',
        ExpressionAttributeValues: { ":bookTitle": bookTitle }
    };

    // findbook returns a promise - scan is async.  
    let booksPromise = bsdb.scan( params ).promise();

    // findbook return val is in books
    return booksPromise.then((books) => {

	let book = {};
	books.Items.forEach(function (element) {
	    console.log( "Element: ", element );  
	    book = element;
	});
	console.log( "About to create JSON response, ", book );
	return {
            statusCode: 201,
            body: JSON.stringify({
                BookId: bookId,
                Title: book.Title,
		Author: book.Author,
		MagicCookie: book.ISBN,
                User: username
            }),
            headers: {
                'Access-Control-Allow-Origin': '*',
            }
	};
	
    });
}


function recordBook(bookId, username, book) {
    return bsdb.put({
        TableName: 'Books',
        Item: {
            BookId: bookId,
            User: username,
            Title: book.title,
            RequestTime: new Date().toISOString()
        },
    }).promise();
}

function toUrlString(buffer) {
    return buffer.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

function errorResponse(status, errorMessage, awsRequestId) {
    return {
	statusCode: status, 
	body: JSON.stringify({
	    Error: errorMessage,
	    Reference: awsRequestId,
	}),
	headers: { 'Access-Control-Allow-Origin': '*' }
    };
}
