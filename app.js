/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: app.js
Purpose: Set up a simple server + routes for viewing database via simple UI.

Original work. No AI or external resources were used.
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
    res.redirect('/users');
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
    LISTENER
*/

app.listen(PORT, () => {
    console.log(`Express started on http://classwork.engr.oregonstate.edu:${PORT}`);
});