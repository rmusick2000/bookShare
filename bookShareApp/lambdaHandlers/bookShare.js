// BookShare

const AWS = require('aws-sdk');
const bsdb = new AWS.DynamoDB.DocumentClient();
const randomBytes = require('crypto').randomBytes;

exports.handler = (event, context, callback) => {

    console.log( 'BookShare Handler start' );

    if (!event.requestContext.authorizer) {
      errorResponse('Authorization not configured, dude', context.awsRequestId, callback);
      return;
    }
    
    const bookId = toUrlString(randomBytes(16));
    console.log('Received event (', bookId, '): ', event);

    // Because we're using a Cognito User Pools authorizer, all of the claims
    // included in the authentication token are provided in the request context.
    // This includes the username as well as other attributes.
    const username = event.requestContext.authorizer.claims['cognito:username'];

    // The body field of the event in a proxy integration is a raw string.
    // In order to extract meaningful values, we need to first parse this string
    // into an object. A more robust implementation might inspect the Content-Type
    // header first and use a different parsing strategy based on that value.
    const requestBody = JSON.parse(event.body);

    const bookTitle = requestBody.Title;

    // findbook returns a promise - scan is async.  
    let booksPromise = findBook(bookTitle);
    // findbook return val is in books
    booksPromise.then((books) => {

	// XXX cleanme
	let res = {};
	let book = {};
	books.Items.forEach(function (element) {
	    console.log( "Element: ", element );
	    book = element;
	    res.Title = element.Title;
	    res.Author = element.Author;
	    res.MagicCookie = element.ISBN;
	});
	console.log('Results: ', res );
	
	console.log( "About to create JSON response, ", book );

	callback(null, {
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
            },
        });
    }).catch((err) => {
        console.error(err);
        // If there is an error during processing, catch it and return
        // from the Lambda function successfully. Specify a 500 HTTP status
        // code and provide an error message in the body. This will provide a
        // more meaningful error response to the end client.
        errorResponse(err.message, context.awsRequestId, callback);
    });
};

// Scan.. not cheap.. XXX TEMP for testing
function findBook(bookTitle) {
    console.log('Finding book for ', bookTitle );

    // Title must be :bookTitle, where :bookTitle = bookTitle.  grack.
    const params = {
        TableName: 'Books',
        FilterExpression: 'Title = :bookTitle',
        ExpressionAttributeValues: { ":bookTitle": bookTitle }
    };

    return bsdb.scan( params ).promise();
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

function errorResponse(errorMessage, awsRequestId, callback) {
  callback(null, {
    statusCode: 500,
    body: JSON.stringify({
      Error: errorMessage,
      Reference: awsRequestId,
    }),
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  });
}
