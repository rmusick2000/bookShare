// BookShare

const AWS = require('aws-sdk');
const bsdb = new AWS.DynamoDB.DocumentClient();
var assert = require('assert');

// sigh.  thanks dynamodb.  
const EMPTY = "---EMPTY---";  

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
    const rb = JSON.parse(event.body);

    var endPoint = rb.Endpoint;
    var resultPromise;

    if(      endPoint == "FindBook" )      { resultPromise = findBook( rb.Title, username ); }
    else if( endPoint == "GetLibs")        { resultPromise = getLibs( username, true); }
    else if( endPoint == "GetExploreLibs") { resultPromise = getLibs( username, false ); }
    else if( endPoint == "GetBooks")       { resultPromise = getBooks( rb.SelectedLib ); }
    else if( endPoint == "PutBook")        { resultPromise = putBook( rb.SelectedLib, rb.NewBook, username ); }
    else if( endPoint == "PutPerson")      { resultPromise = putPerson( rb.NewPerson ); }
    else if( endPoint == "PutLib")         { resultPromise = putLib( rb.NewLib ); }
    else if( endPoint == "DelLib")         { resultPromise = delLib( rb.LibId, rb.PersonId ); }
    else if( endPoint == "DelBook")        { resultPromise = delBook( rb.BookId, rb.PersonId ); }
    else if( endPoint == "GetOwnerships")  { resultPromise = getOwnerships( rb.PersonId ); }
    else if( endPoint == "UpdateShare")    { resultPromise = updateShare( rb.BookId, rb.PersonId, rb.LibId, rb.PLibId, rb.All, rb.Value ); }
    else if( endPoint == "InitOwnership")  { resultPromise = initOwn( username, rb.PrivLibId ); }
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

// XXX
// ownershipId == personId
// books: list <map<bookid, sharecount>> (actually, not)  -->
// books: map<bookid, list<int>>   list: sharecount, ?, ?
// shares: map<libid, stringset<bookid> >
function lookupOwnerships( personId ) {
    console.log('Get shares! ', personId );

    const paramsO = {
        TableName: 'Ownerships',
        FilterExpression: 'OwnershipId = :uid',
        ExpressionAttributeValues: { ":uid": personId }
    };
    
    let ownershipsPromise = bsdb.scan( paramsO ).promise();
    return ownershipsPromise.then((ownerships) => {
	assert( ownerships.Count == 1 );
	
	return ownerships.Items[0];
    });
}

function lookupLibraries( personId, memberLibs ) {
    console.log('LookupLibs!', personId, memberLibs  );

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
    
    let librariesPromise = bsdb.scan( paramsL ).promise();
    return librariesPromise.then((libraries) => {
	console.log( libraries );
	return libraries;
    });
}

async function initOwn( username, privLib ) {
    console.log('init ownership', username );

    const personId  = await getPersonId( username );
	
    // Update ownership.. pkey is same as PersonId
    const paramsO = {
	TableName:     'Ownerships',
	Item: {
	    "OwnershipId": personId, 
	    "Books":       {},
	    "Shares":      {}
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

// XXX kill selectedLib
// Want some error msgs? https://github.com/aws/aws-sdk-js/issues/2464
// Updates tables: Books, Ownerships
async function putBook( selectedLib, newBook, username ) {
    console.log('Put Book!', username, selectedLib, newBook.title );

    const personId   = await getPersonId( username );
    const libraryId  = await getPrivLibId( personId );
    const ownerships = await lookupOwnerships( personId );
    
    // Books is map<string, list>  id: attributes
    let newBooks = ownerships.Books;
    let oEntry = [0];
    newBooks[newBook.id] = oEntry;
    
    // Deal with dynamodb set object.. grr  can't just newShares.add( newBook.id );
    let   newShares = ownerships.Shares;
    var sharesSet;
    if( newShares[libraryId] != null ) { sharesSet = new Set( newShares[libraryId].values ); }
    else {
	newShares[libraryId] = new Set();
	newShares[libraryId].wrapperName = 'Set';
	newShares[libraryId].type = 'String';
	sharesSet = new Set();
    }

    sharesSet.add( newBook.id );
    newShares[libraryId].values = Array.from( sharesSet );

    const paramsO = {
	TableName: 'Ownerships',
	Key: { "OwnershipId": personId },
	UpdateExpression: 'set Books = :newBooks, Shares = :newShares',
        ExpressionAttributeValues: {
            ':newBooks':  newBooks, ':newShares': newShares
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
    
    let bookPromise = bsdb.transactWrite({
	TransactItems: [
	    { Put: paramsPB }, 
	    { Update: paramsO },
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

async function putPerson( newPerson ) {
    console.log('Put Person!', newPerson.firstName );

    const paramsPP = {
	TableName: 'People',
	Item: {
	    "PersonId": newPerson.id,
	    "First":    newPerson.firstName,
	    "Last":     newPerson.lastName,
	    "UserName": newPerson.userName,
	    "Email":    newPerson.email,
	    "ImagePng": newPerson.imagePng            
	}
    };
    
    let personPromise = bsdb.put( paramsPP ).promise();
    return personPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}

async function putLib( newLib ) {
    console.log('Put Lib!', newLib.name );

    const paramsPL = {
	TableName: 'Libraries',
	Item: {
	    "LibraryId":   newLib.id,
	    "JustMe":      newLib.private,
	    "LibraryName": newLib.name,
	    "Members":     newLib.members,
	    "Description": newLib.description,
	    "ImagePng":    newLib.imagePng            
	}
    };
    
    let libPromise = bsdb.put( paramsPL ).promise();
    return libPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}


async function delLib( libId, personId ) {
    console.log('Kill Lib!', libId, personId );

    const ownerships = await lookupOwnerships( personId );
    const myLibs = await lookupLibraries( personId, true );
    var shares = ownerships.Shares;
    
    var newShares = new Map();

    // XXX Can't seem to create the easy way.. rebuild from scratch
    if( shares[libId] != null ) {
	myLibs.Items.forEach( function(lib) { if( lib.LibraryId != libId ) { newShares[lib.LibraryId] = shares[lib.LibraryId]; } });
    }

    const paramsO = {
        TableName: 'Ownerships',
	Key: {"OwnershipId": personId},
	UpdateExpression: 'set Books = :books, Shares = :newShares',
	ExpressionAttributeValues: { ':books': ownerships.Books, ':newShares': newShares }};
    
    const paramsPL = {
	TableName: 'Libraries',
	Key: {"LibraryId": libId }};
    
    // Allow re-update of ownership even if no change.
    let libPromise = bsdb.transactWrite({
	TransactItems: [
	    { Delete: paramsPL },
	    { Update: paramsO },
	]}).promise();
    
    return libPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}

// XXX Books table is unaltered.  Just the ownership of the book.  Desired behavior?
async function delBook( bookId, personId ) {
    console.log('Del book!', bookId, personId );

    const ownerships = await lookupOwnerships( personId );
    var books  = ownerships.Books;
    var shares = ownerships.Shares;

    // XXX Slow with many books.  There must be a more sensible way.  books.delete fails - books is iterable but does not have delete.
    //     if try creating as newBooks = new Map( Object.entries( books )), 
    //     creates some type of ... procedural map:  Books post-del Map { 'TAXJLUCDRK' => [ 0 ], 'vlSfhriyvh' => [ 0 ] }
    //     which dynamo can't load back in.  
    var newBooks = new Map();
    for( var bid in books ) { if( bid != bookId ) { newBooks[bid] = books[bid]; }}
    
    for (var libid in shares) {
	var bookSet = new Set( shares[libid].values );
	bookSet.delete( bookId );
	// stringsets can't have empty set
	if( bookSet.size == 0 ) { bookSet.add( EMPTY ); }
	shares[libid].values = Array.from( bookSet );
    }
    
    const paramsO = {
        TableName: 'Ownerships',
	Key: {"OwnershipId": personId},
	UpdateExpression: 'set Books = :books, Shares = :shares',
	ExpressionAttributeValues: { ':books': newBooks, ':shares': shares }};
    

    let libPromise = bsdb.transactWrite({
	TransactItems: [
	    { Update: paramsO },
	]}).promise();

    return libPromise.then(() => {
	console.log("Success!");
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}

// XXX Beware 100 item limit in scan
function getBooks( selectedLib ) {
    console.log('Get Books!', selectedLib );

    // Note the # instead of : for attribute name, not value
    // Params to get ownerships that have selectedLib in shares
    const paramsO = {
        TableName: 'Ownerships',
        FilterExpression: 'attribute_exists(Shares.#lid)',
        ExpressionAttributeNames: { "#lid": selectedLib }
    };
    
    let ownershipsPromise = bsdb.scan( paramsO ).promise();
    return ownershipsPromise.then((ownerships) => {
	var books = [];
	if( ownerships.Count > 0 ) {
	    ownerships.Items.forEach(function(ownership) {
		books = books.concat( Array.from( ownership.Shares[selectedLib].values ) );
	    });
	}
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


async function getOwnerships( personId ) {
    console.log('Get ownerships! ', personId );
    const ownerships = await lookupOwnerships( personId );

    return {
	statusCode: 201,
	body: JSON.stringify( ownerships ),
	headers: { 'Access-Control-Allow-Origin': '*' }
    };
}

// XXX test dbase for initOwn
// data volume is tiny, put is overwrite... so just grab, rebuild and put
async function updateShare( bookId, personId, libId, plibId, all, value ) {
    console.log('Put share(s) for', libId, personId, "all?", all );

    const ownerships = await lookupOwnerships( personId );
    var shares = ownerships.Shares;

    // dynamodb unmarshalling in order to use as a set.  shares is not a map, but still has [] method
    var sharesSet;
    if( shares[libId] != null ) { sharesSet = new Set( shares[libId].values ); }
    else {
	// initialize set from one we know exists.  this is an odd dynamodb object
	shares[libId] = Object.assign( {}, shares[plibId] );
	console.log( shares[libId], shares[plibId] );
	sharesSet = new Set();
    }
    const booksSet  = new Set( shares[plibId].values );
    
    if( value == "true" ) {
	if( all == "true" ) { sharesSet = booksSet;    }
	else                { sharesSet.add( bookId ); }
    }
    else {
	if( all == "true" ) { sharesSet.clear(); }
	else                { sharesSet.delete( bookId ); }

	// Libraries can't have empty set
	if( sharesSet.size == 0 ) { sharesSet.add( EMPTY ); }
	
    }
    assert( sharesSet.size > 0 );
    shares[libId].values = Array.from( sharesSet ); 
    
    const paramsO = {
        TableName: 'Ownerships',
	Item: {
	    "OwnershipId":  personId,
	    "Books":        ownerships.Books,
	    "Shares":       shares
	}};
    
    let ownershipsPromise = bsdb.put( paramsO ).promise();
    return ownershipsPromise.then((ownership) => {
	console.log( "Success!" );
	return {
	    statusCode: 201,
	    body: JSON.stringify( true ),
	    headers: { 'Access-Control-Allow-Origin': '*' }
	};
    });
}

async function getLibs( userName, memberLibs ) {

    const personId  = await getPersonId( userName );
    const libraries = await lookupLibraries( personId, memberLibs );
    
    // exploring, can have 0 libs
    if( libraries.Count >= 1 ) {
	console.log( "Result: ", libraries.Count );
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
