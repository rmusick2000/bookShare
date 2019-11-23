// BookShare

const AWS = require('aws-sdk');
const bsdb = new AWS.DynamoDB.DocumentClient();
const randomBytes = require('crypto').randomBytes;
var assert = require('assert');

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

    if(      endPoint == "FindBook" )      { resultPromise = findBook( requestBody.Title, username ); }
    else if( endPoint == "GetLibs")        { resultPromise = getLibs( username, true); }
    else if( endPoint == "GetExploreLibs") { resultPromise = getLibs( username, false ); }
    else if( endPoint == "GetBooks")       { resultPromise = getBooks( requestBody.SelectedLib, username ); }
    else if( endPoint == "PutBook")        { resultPromise = putBook( requestBody.SelectedLib, requestBody.NewBook, username ); }
    else if( endPoint == "GetShares")      { resultPromise = getShares( requestBody.PersonId ); }
    else if( endPoint == "UpdateShare")    { resultPromise = updateShare( requestBody.BookId, requestBody.PersonId, requestBody.LibId, requestBody.Value ); }
    else if( endPoint == "InitOwnership")  { resultPromise = initOwn( username ); }
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


function getPersonId( username ) {
    // Params to get PersonID from UserName
    const paramsP = {
        TableName: 'People',
        FilterExpression: 'UserName = :uname',
        ExpressionAttributeValues: { ":uname": username }
    };

    let personPromise = bsdb.scan( paramsP ).promise();
    return personPromise.then((persons) => {
	console.log( "Persons: ", persons );
	assert(persons.Count == 1 );
	console.log( "Found person ", persons.Items[0] );
	return persons.Items[0].PersonId;
    });
}

function getPrivLibId( personId ) {
    // Params to get Private LibraryId from personId
    const paramsPL = {
        TableName: 'Libraries',
        FilterExpression: 'contains( Members, :pid ) AND JustMe = :true',
        ExpressionAttributeValues: { ":pid": personId, ":true": true }
    };
    
    let libraryPromise = bsdb.scan( paramsPL ).promise();
    return libraryPromise.then((libraries) => {
	console.log( "Libraries: ", libraries );
	assert(libraries.Count == 1 );
	console.log( "Found Private Library ", libraries.Items[0] );
	return libraries.Items[0].LibraryId;
    });
}

function getShareLibs( bookId, personId ) {
    // Params to get a shares
    const paramsS = {
        TableName: 'LibraryShares',
        FilterExpression: 'BookId = :bid AND PersonId = :pid',
        ExpressionAttributeValues: { ":bid": bookId, ":pid": personId }
    };
    
    let sharePromise = bsdb.scan( paramsS ).promise();
    return sharePromise.then((shares) => {
	console.log( "shares: ", shares );
	assert(shares.Count == 1 );
	return shares.Items[0].Libraries;
    });
}


async function initOwn( username ) {
    console.log('init ownership', username );

    const personId  = await getPersonId( username );
	
    // Update ownership.. pkey is same as PersonId
    const paramsO = {
	TableName:     'Ownerships',
	Item: {
	    "OwnershipId": personId, 
	    "Books":       []
	}
    };

    let initPromise = bsdb.transactWrite({
	TransactItems: [
	    { Put: paramsO }
	]}).promise();
    
    return initPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
    
}    

// Want some error msgs? https://github.com/aws/aws-sdk-js/issues/2464
// Updates tables: Books, LibraryShares, Ownerships
async function putBook( selectedLib, newBook, username ) {
    console.log('Put Book!', username, selectedLib, newBook.title );

    const personId  = await getPersonId( username );
    const libraryId = await getPrivLibId( personId );
	
    // Update ownership.. pkey is same as PersonId
    const oEntry = [{ "BookId" : newBook.id, "ShareCount" : 0 }];
    const paramsO = {
	TableName: 'Ownerships',
	Key: { "OwnershipId": personId },
	UpdateExpression: 'set Books = list_append(Books, :nb)',
        ExpressionAttributeValues: {
            ':nb':  oEntry
        }
    };
    
    // Put book 
    const paramsPB = {
	TableName: 'Books',
	Item: {
	    "BookId":      newBook.id,
	    "Author":      newBook.author,
	    "Title":       newBook.title,
	    "ISBN":        newBook.ISBN,
	    "Publisher":   newBook.publisher,
	    "PublishedDate": newBook.publishedDate,
	    "PageCount":   newBook.pageCount,
	    "Description": newBook.description,
	    "ImageSmall":  newBook.imageSmall,
	    "Image":       newBook.image            
	}
    };
    
    // Put libshares
    const lsEntry = [ libraryId ];
    console.log( "libshare entry", lsEntry );
    const paramsLS = {
	TableName: 'LibraryShares',
	Item: {
	    "BookId":      newBook.id,
	    "PersonId":    personId,
	    "Libraries":   lsEntry,
	}
    };
    
    let bookPromise = bsdb.transactWrite({
	TransactItems: [
	    { Put: paramsPB }, 
	    { Update: paramsO },
	    { Put: paramsLS }
	]}).promise();
    
    return bookPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}


// XXX Beware 100 item limit in scan
function getBooks( selectedLib, username ) {
    console.log('Get Books! ' + username + selectedLib );

    // Get Shares
    
    // Params to get shares that have selectedLib in Libraries
    const paramsS = {
        TableName: 'LibraryShares',
        FilterExpression: 'contains(Libraries, :lid)',
        ExpressionAttributeValues: { ":lid": selectedLib }
    };
    
    let sharesPromise = bsdb.scan( paramsS ).promise();
    return sharesPromise.then((shares) => {
	console.log( "Shares: ", shares );
	var books = [];
	shares.Items.forEach(function(share) {
	    books.push( share.BookId );
	});
	return books;
    }).then((books) => {

	// Get Books for shares

	// Params to get Books that are in books
	const paramsB = {
	    TableName: 'Books',
	    FilterExpression: 'contains(:books, BookId)',
	    ExpressionAttributeValues: { ":books": books }
	};

	let booksPromise = bsdb.scan( paramsB ).promise();
	return booksPromise.then((books) => {
	    
	    console.log( "Result: ", books );
	    return {
		statusCode: 201,
		body: JSON.stringify( books.Items ),
		headers: { 'Access-Control-Allow-Origin': '*' }
	    };
	});
	
    });
}

// XXX Beware 100 item limit in scan
function getShares( personId ) {
    console.log('Get shares! ', personId );

    // Get Shares
    
    // Params to get shares for personId
    const paramsS = {
        TableName: 'LibraryShares',
        FilterExpression: 'PersonId = :uid',
        ExpressionAttributeValues: { ":uid": personId }
    };
    
    let sharesPromise = bsdb.scan( paramsS ).promise();
    return sharesPromise.then((shares) => {
	
	return {
	    statusCode: 201,
	    body: JSON.stringify( shares.Items ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}




// 1. At this point, share has been added for private lib.  update with append, or remove.
// 2. list_append exists, but there is no list_delete.
//    data volume is tiny, put is overwrite... so just grab, rebuild and put
async function updateShare( bookId, personId, libId, value ) {

    var libraries = await getShareLibs( bookId, personId );
    console.log('Put share, current libs:', libraries );

    if( value == "true" ) {
	libraries.push( libId );
    } else {
	var index = libraries.indexOf( libId );
	assert( index > -1 );
	libraries.splice( index, 1 );
    }
    
    // Params to put share
    const paramsS = {
        TableName: 'LibraryShares',
	Item: {
	    "BookId":    bookId,
	    "PersonId":  personId,
	    "Libraries": libraries
	}};
    
    let sharesPromise = bsdb.put( paramsS ).promise();
    return sharesPromise.then((shares) => {
	console.log( "Success!" );
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}

async function getLibs( username, memberLibs ) {
    console.log('Get Libs!', username, memberLibs  );

    const personId  = await getPersonId( username );

    // Params to get Libraries that have PersonID in Members
    var paramsL;
    if( memberLibs ) {
	paramsL = {
            TableName: 'Libraries',
            FilterExpression: 'contains(Members, :pid)',
            ExpressionAttributeValues: { ":pid": personId }
	};
    } else {
	paramsL = {
            TableName: 'Libraries',
            FilterExpression: 'NOT contains(Members, :pid) AND JustMe = :false',
            ExpressionAttributeValues: { ":pid": personId, ":false": false }
	};
    }
    
    console.log( "Working with ", personId );
    let librariesPromise = bsdb.scan( paramsL ).promise();
    return librariesPromise.then((libraries) => {

	// exploring, can have 0 libs
	if( libraries.Count >= 1 ) {
	    console.log( "Result: ", libraries );
	    return {
		statusCode: 201,
		body: JSON.stringify( libraries.Items ),
		headers: { 'Access-Control-Allow-Origin': '*' }
	    };
	} else
	{
	    console.log( "Result: no libs" );
	    return {
		statusCode: 204,
		body: JSON.stringify( "---" ),
		headers: { 'Access-Control-Allow-Origin': '*' }
	    };
	}
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

	console.log( "Result: ", book );
	return {
            statusCode: 201,
            body: JSON.stringify( book ),
            headers: { 'Access-Control-Allow-Origin': '*' }
	};
	
    });
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
