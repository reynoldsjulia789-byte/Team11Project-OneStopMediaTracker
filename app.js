/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: app.js
Purpose: Set up a simple server + routes for viewing database via simple UI.

Original work. No AI used.
CRUD procedures adapted from:
- CS340 Exploration - Implementing CUD operations in your app (https://canvas.oregonstate.edu/courses/2031764/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=26243436)
*/


/*
    SETUP
*/

const express = require('express');

// use Handlebars for templating (as suggested in Step 3)
const exphbs = require('express-handlebars');

// set up our dabatase connection
const db = require('./database/db-connector');

const app = express();
const PORT = 9130;

// set up Handlebars for templating
app.engine('.hbs', exphbs.engine({ extname: '.hbs' }));
app.set('view engine', '.hbs');
app.set('views', './views');

// set up middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static('public'));


/*
    ROUTES
*/

// Home / index page
app.get('/', (req, res) => {
    res.render('index');
});

// get all users from the database and render them in the users.hbs template
app.get('/users', async (req, res) => {
  try {
    const query = 'SELECT userID, username, email FROM Users;';
    const [rows] = await db.query(query);
    res.render('users', { data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// get all media items from the database and render them in the media-items.hbs template
app.get('/media-items', async (req, res) => {
  try {
    const query = `
      SELECT mediaItemID, mediaType, title, DATE_FORMAT(releaseDate, '%b %e, %Y') AS releaseDate, runtimeMins, creator, platform
      FROM MediaItems;
    `;
    const [rows] = await db.query(query);
    res.render('media-items', { data: rows });
  } catch (err) {
    console.error('DB error on /media-items:', err);
    res.status(500).send('Database error');
  }
});

// get all sports events from the database and render them in the sports-events.hbs template
app.get('/sports-events', async (req, res) => {
  try {
    const query = `
      SELECT 
        sportsEventID, 
        typeOfSport, 
        homeTeam, 
        awayTeam, 
        DATE_FORMAT(startTime, '%b %e, %Y %h:%i %p') AS startTime, 
        runtimeMins, 
        CASE
          WHEN recordingIsAvailable = 1 THEN 'Available'
          ELSE 'Unavailable'
        END AS recordingIsAvailable,
        platform
      FROM SportsEvents;
    `;
    const [rows] = await db.query(query);
    res.render('sports-events', { data: rows });
  } catch (err) {
    console.error('DB error on /sports-events:', err);
    res.status(500).send('Database error');
  }
});

// get all tracker entries from the database and render them (updated with JOINs to address FKs)
// now includes date formatting to make the timestamps easier to read
app.get('/tracker-entries', async (req, res) => {
  try {
    const query = `
      SELECT
        ute.entryID,
        u.username AS user,
        COALESCE(
          mi.title,
          CONCAT(se.awayTeam, ' @ ', se.homeTeam)
        ) AS trackedItem,
        ute.status,
        DATE_FORMAT(ute.savedAt, '%b %e, %Y %h:%i %p') AS savedAt,
        DATE_FORMAT(ute.completedAt, '%b %e, %Y %h:%i %p') AS completedAt
      FROM UserTrackerEntries ute
      JOIN Users u ON ute.userID = u.userID
      LEFT JOIN MediaItems mi ON ute.mediaItemID = mi.mediaItemID
      LEFT JOIN SportsEvents se ON ute.sportsEventID = se.sportsEventID
      ORDER BY ute.entryID;
    `;
    const [rows] = await db.query(query);
    res.render('tracker-entries', { data: rows });
  } catch (err) {
    console.error('DB error on /tracker-entries:', err);
    res.status(500).send('Database error');
  }
});

// reset database (calls stored procedure)
app.get('/reset', async (req, res) => {
  try {
    await db.query('CALL sp_reset_nextup();');
    res.redirect('/index');
  } catch (err) {
    console.error('RESET failed:', err);
    res.status(500).send('RESET failed. 😞 Check server console.');
  }
});

// hard-coded delete demo (calls stored procedure)
app.get('/demo-delete', async (req, res) => {
  try {
    await db.query('CALL sp_demo_delete_user();');
    return res.redirect('/users');
  } catch (err) {
    console.error('Demo delete failed:', err);
    return res.status(500).send('Demo delete failed.');
  }
});

/*
   USER PROCEDURES
*/

// insert user
app.post('/users/insert', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // Cleanse data
        if (!data.email || !data.username)
        {
          // send bad request error
          res.status(400).send
          (
            'please provide valid inputs'
          );

          return;
        }

        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_insertUser(?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1,
        [
          data.username,
          data.email
        ]);

        console.log(`created user: userID: ${rows.new_id} username: ${data.username} ${data.email}`);

        // Redirect the user to the updated webpage
        res.redirect('/users');
    } 
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// update user
app.post('/users/update', async function (req, res)
{
    try {
        // Parse frontend form information
        const data = req.body;

        // Cleanse data
        if (isNaN(parseInt(data.userID)) || !data.email || !data.username)
        {
          // send bad request error
          res.status(400).send
          (
            'please provide valid inputs'
          );

          return;
        }

        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_updateUser(?, ?, ?);';

        // get new row information
        const query2 = 'SELECT username, email FROM Users WHERE userID = ?;';

        // execute update stored procedure
        await db.query(query1,
        [
          data.userID,
          data.username,
          data.email
        ]);
        
        // get updated data from database
        const [[rows]] = await db.query(query2, [data.userID]);

        console.log
        (
          `updated Users table, userID: ${data.userID} username: ${rows.username}, email: ${rows.email}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/users');
    }
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while executing the database queries.'
        );
    }
});

// delete user
app.post('/users/delete', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_deleteUser(?);`;
        await db.query(query1, [data.delete_userID]);

        console.log(`delete userID: ${data.delete_userID} `);

        // Redirect the user to the updated webpage data
        res.redirect('/users');
    } 
    catch (error)
    {
        console.error('Error executing delete user:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while deleting the user.'
        );
    }
});

/*
   SPORTS EVENTS PROCEDURES
*/

// insert event
app.post('/sports-events/insert', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // TODO: add data cleansing 
        
        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_insertSportsEvent(?, ?, ?, ?, ?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1,
        [
          data.typeOfSport,
          data.homeTeam,
          data.awayTeam,
          data.startTime,
          data.runtimeMins,
          data.recordingIsAvailable,
          data.platform
        ]);

        console.log
        (
          `created sports event: +
          sportsEventID: ${rows.new_id}, +
          type of sport: ${data.typeOfSport}, +
          homeTeam: ${data.homeTeam}, +
          awayTeam: ${data.awayTeam}, +
          startTime: ${data.startTime}, +
          runtime mins: ${data.runtimeMins}, +
          recording?: ${data.recordingIsAvailable}, +
          platform: ${data.platform}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/sports-events');
    } 
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// update sports event
app.post('/sports-events/update', async function (req, res)
{
    try
    {
        // Parse frontend form information
        const data = req.body;

        // TODO: add data verification/cleanse

        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_updateSportsEvents(?, ?, ?, ?, ?, ?, ?, ?);';

        // get new row information
        const query2 = 'SELECT * FROM SportsEvents WHERE sportsEventID = ?;';

        // execute update stored procedure
        await db.query(query1,
        [
          data.sportsEventID,
          data.typeOfSport,
          data.homeTeam,
          data.awayTeam,
          data.startTime,
          data.runtimeMins,
          data.recordingIsAvailable,
          data.platform
        ]);
        
        // get updated data from database
        const [[rows]] = await db.query(query2, [data.sportsEventID]);

        console.log
        (
          `updated sports event: +
          sportsEventID: ${data.sportsEventID}, +
          type of sport: ${rows.typeOfSport}, +
          homeTeam: ${rows.homeTeam}, +
          awayTeam: ${rows.awayTeam}, +
          startTime: ${rows.startTime}, +
          runtime mins: ${rows.runtimeMins}, +
          recording?: ${rows.recordingIsAvailable}, +
          platform: ${rows.platform}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/sports-events');
    }
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while executing the database queries.'
        );
    }
});

// delete sports event
app.post('/sports-events/delete', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_deleteSportsEvent(?);`;
        await db.query(query1, [data.delete_sportsEventID]);

        console.log(`delete sportsEventID: ${data.delete_sportsEventID} `);

        // Redirect the user to the updated webpage data
        res.redirect('/sports-events');
    } 
    catch (error)
    {
        console.error('Error executing delete:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while deleting the user.'
        );
    }
});

/*
   MEDIA ITEMS PROCEDURES
*/

// insert media item
app.post('/media-items/insert', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // TODO: add data cleansing 
        
        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_insertMediaItem(?, ?, ?, ?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1,
        [
          data.mediaType,  
          data.title,      
          data.releaseDate,
          data.runtimeMins,
          data.creator,    
          data.platform
        ]);

        console.log
        (
          `created media item: +
          mediaItemID: ${rows.new_id}, +
          media type: ${data.mediaType}, +
          title: ${data.title}, +
          release date: ${data.releaseDate}, +
          runtimeMins: ${data.runtimeMins}, +
          creator: ${data.creator}, +
          platform: ${data.platform}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/media-items');
    } 
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// update media item
app.post('/media-items/update', async function (req, res)
{
    try
    {
        // Parse frontend form information
        const data = req.body;

        // TODO: add data verification/cleanse

        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_updateMediaItem(?, ?, ?, ?, ?, ?, ?);';

        // get new row information
        const query2 = 'SELECT * FROM MediaItems WHERE mediaItemID = ?;';

        // execute update stored procedure
        await db.query(query1,
        [
          data.mediaItemID,
          data.mediaType,  
          data.title,      
          data.releaseDate,
          data.runtimeMins,
          data.creator,    
          data.platform
        ]);
        
        // get updated data from database
        const [[rows]] = await db.query(query2, [data.mediaItemID]);

        console.log
        (
          `updated media item: +
          mediaItemID: ${rows.mediaItemID}, +
          media type: ${rows.mediaType}, +
          title: ${rows.title}, +
          release date: ${rows.releaseDate}, +
          runtimeMins: ${rows.runtimeMins}, +
          creator: ${rows.creator}, +
          platform: ${rows.platform}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/media-items');
    }
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while executing the database queries.'
        );
    }
});

// delete media items
app.post('/media-items/delete', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_deleteMediaItem(?);`;
        await db.query(query1, [data.delete_mediaItemID]);

        console.log(`delete mediaItemID: ${data.delete_mediaItemID} `);

        // Redirect the user to the updated webpage data
        res.redirect('/media-items');
    } 
    catch (error)
    {
        console.error('Error executing delete:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while deleting the user.'
        );
    }
});

/*
   USER TRACKER ENTRIES PROCEDURES
*/

// insert user tracker entry
app.post('/tracker-entries/insert', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // TODO: add data cleansing 
        
        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_insertTrackerEntry(?, ?, ?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1,
        [
          data.username,  
          data.trackedItem,      
          data.status,
          data.savedAt,
          data.completedAt
        ]);

        console.log
        (
          `created tracker entry: +
          entryid: ${rows.new_id}, +
          username: ${data.username}, +
          tracked item: ${data.trackedItem}, +
          status: ${data.status}, +
          savedAt: ${data.savedAt}, +
          status: ${data.completedAt}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/tracker-entries');
    } 
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// update tracker entry
app.post('/tracker-entries/update', async function (req, res)
{
    try
    {
        // Parse frontend form information
        const data = req.body;

        // TODO: add data verification/cleanse

        // create query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = 'CALL sp_updateTrackerEntry(?, ?, ?);';

        // get new row information
        const query2 = 'SELECT * FROM UserTrackerEntries WHERE entryID = ?;';

        // execute update stored procedure
        await db.query(query1,
        [
          data.entryID,
          data.status,  
          data.completedAt
        ]);
        
        // get updated data from database
        const [[rows]] = await db.query(query2, [data.entryID]);

        console.log
        (
          `updated entry: +
          entryID: ${rows.entryID}, +
          userID: ${rows.userID}, +
          mediaItemID: ${rows.mediaItemID}, +
          sportsEventID: ${rows.sportsEventID}, +
          status: ${rows.status}, +
          savedAt: ${rows.savedAt}, +
          completedAT: ${rows.completedAt}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/tracker-entries');
    }
    catch (error)
    {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while executing the database queries.'
        );
    }
});

// delete tracker entry
app.post('/tracker-entries/delete', async function (req, res)
{
    try
    {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_deleteTrackerEntry(?);`;
        await db.query(query1, [data.delete_entryID]);

        console.log(`delete entry: ${data.delete_entryID} `);

        // Redirect the user to the updated webpage data
        res.redirect('/tracker-entries');
    } 
    catch (error)
    {
        console.error('Error executing delete:', error);
        // Send a generic error message to the browser
        res.status(500).send
        (
            'An error occurred while deleting the user.'
        );
    }
});

/*
    LISTENER
*/

app.listen(PORT, () => {
    console.log(`Express started on http://classwork.engr.oregonstate.edu:${PORT}`);
});