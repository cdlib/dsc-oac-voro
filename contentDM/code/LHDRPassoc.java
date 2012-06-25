/*************************************************************************/
/*									 */
/* IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT */
/*									 */
/*	If you modify this file (or copy this file, and modify		 */
/*	the copy) and do not update this set of comments at the		 */
/*	top, then delete this set of comments at the top, in its	 */
/*	entirety.  Failure to do that may result in someone		 */
/*	later on reading the then-misleading comments at the top,	 */
/*	acting based on the comments' description of how/what		 */
/*	the script does, and making a serious mistake.			 */
/*									 */
/* IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT */
/*									 */
/*************************************************************************/

/*
 * ------------------------------------
 *
 * Project:	Yearly LHDRP 7train Processing
 *
 * Task:	Keep track of existing associations needed by the
 *		XSLT, and make and record new associations, when needed,
 *		using the Oracle/SleepyCat port of BerkeleyDB to Java.
 *
 * Name:	LHDRPassoc
 *
 * Use:		Usual use of this class is for XSLT to access the static
 *		method "getAssoc".  It's string parameter is the local id
 *		to seek, and its return is an ARK number.
 *
 * Command line use:  This class may also be used from the command line.
 *		Command line options can be used to maintain the BerkeleyDB
 *		database.
 *
 *		The first command line parameter is the operation code.  The
 *		command line parameters that follow it, if any, depend on it.
 *		Following lists the operation codes, and the additional
 *		parameters they use.  Any addition parameters shown are
 *		required, and anything more than is shown, gets ignored.
 *		
 *		create (no additional parameters)
 *			brings a BerkeleyDB into existence, and it's an error
 *			if it already exists (the directory in which the
 *			environment is declared, must exist, though.)
 *		
 *		set KEY VALUE
 *			sets the value for key "KEY" to "VALUE" (this is
 *			ouside the database scheme presented above.  that is,
 *			it is possible to set key "UNASSIGNED-max".)
 *		
 *		get KEY
 *			retrieves and displays the value for key "KEY" (this is
 *			outside the database scheme presented above.  that is,
 *			it is possible to display key "UNASSIGNED-244".)
 *		
 *		delete KEY
 *			deletes any value for key "KEY" (this is outside the
 *			database scheme presented above.  that is, it is
 *			possible to delete key "LHDRP-cbc_018".)
 *		
 *		lookup LOCALID
 *			retrieve what's associated with LHDRP local id LOCALID
 *			and display it.  if there is no association, assign an
 *			unassigned ARK number, record the new association, and
 *			display it.  (this uses the database scheme presented
 *			below.)
 *		
 *		dump FILE
 *			dump the contents of the database to file FILE.  if
 *			FILE is "-", dump to STDOUT.
 *
 *		load FILE
 *			load the contents of FILE to the database.  if the
 *			FILE is "-", load from STDIN.  the contents of the
 *			database is wiped clean before loading starts.
 *
 *		unassigned ARK1 [ARK2 [ARK3 ...]]
 *			adds unassigned ARK numbers to the file.  there must
 *			be at least one to add.  there is no (program
 *			specified) upper limit on the number that can be
 *			added.  the format of the value can either be
 *			"ark:/NAAN/NAME" or "NAAN/NAME".
 *
 * Database scheme:
 *		NO BLANKS IN ANY KEYS:  The current coding of the "dump" and
 *		"load" operations depends on there not being a blank in any
 *		key in the database.
 *
 *		A BerkeleyDB is a set of key/value pairs.  We'll store two
 *		kinds of information in this BerkeleyDB:  (1)  associations
 *		between local ids (LHDRP and non-LHDRP) and ARK numbers and
 *		(2)  a set of unassigned ARK numbers, that can be assigned
 *		to a local id when one is found not to have such an
 *		association.  In order to distinguish between these two
 *		different kinds of information, their keys will have different
 *		prefixes.  The key for an LHDRP local id will start with
 *		"LHDRP-".  The key for a non-LHDRP local id will start with
 *		"nonLHDRP-".  The key for information about unassigned ARK
 *		numbers will start with "UNASSIGNED-".  Keys for values that
 *		are unassigned ARK numbers will be "UNASSIGNED-n", where "n"
 *		is a decimal number, with no leading zeros.  The value for
 *		key "UNASSIGNED-min" will be a decimal number for the lowest
 *		"n" of an "UNASSIGNED-n" ARK number.  The value for key
 *		"UNASSIGNED-max" will be a decimal number for the highest "n"
 *		of an "UNASSIGNED-n" ARK number.   For example, the following
 *		key/value pairs might be in the database:
 *		
 *		key			example value
 *		---------------		-----------------------
 *		LHDRP-cb_010		ark:/13030/kt0s20214h
 *		LHDRP-cturs_087		ark:/13030/kt7m3nd444
 *		UNASSIGNED-37		13030/kt109nc9n2
 *		UNASSIGNED-38		13030/kt2x0nd122
 *		UNASSIGNED-39		ark:/13030/kt9199r3vw
 *		UNASSIGNED-40		13030/kt1m3nd1bx
 *		UNASSIGNED-min		37
 *		UNASSIGNED-max		40
 *
 *		LHDRP local ids are case insensitive, and only lower case
 *		local ids appear in the keys.
 *
 * Author:	Michael A. Russell
 *
 * Revision History:
 *		2008/6/10 - MAR - Initial writing
 *		2008/7/10 - MAR - Use resources to get properties file that
 *			contains the pathname to our BerkeleyDB environment
 *			and the name of the database within it.
 *		2008/7/11 - MAR - (1)  Don't allow white space in the local id
 *			during a lookup.  (2)  Have the value of a local id
 *			key be the ARK number, not some XML.
 *		2008/7/11 - MAR - The local id is case insensitive.
 *		2009/5/15 - MAR - We are beginning to process non-LHDRP
 *			contentdm exports.  We have the same need to map
 *			the local identifiers to ARK numbers, but we want
 *			the universe of those local identifiers not to
 *			overlap the universe of the LHDRP local identifiers,
 *			but still use this code.  Fortunately, the LHDRP
 *			local identifiers are prefixed with "LHDRP-" and
 *			then used as keys in the BerkeleyDB.  We can use
 *			a different prefix for the non-LHDRP contentdm
 *			exports.  Make the key prefix a property.  It will
 *			control the "universe" of the local identifiers.
 *
 *      2012/06/25 - MER - Porting to sles linux VM server
 *
 * ------------------------------------
 */

package org.cdlib.dsc.util;

import com.sleepycat.je.Cursor;
import com.sleepycat.je.Database;
import com.sleepycat.je.DatabaseConfig;
import com.sleepycat.je.DatabaseEntry;
import com.sleepycat.je.Environment;
import com.sleepycat.je.EnvironmentConfig;
import com.sleepycat.je.OperationStatus;
import com.sleepycat.je.Transaction;
import java.lang.reflect.Method;
import java.lang.Runtime;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.OutputStreamWriter;
import java.util.Properties;

public class LHDRPassoc
    extends Thread
    {

    /* Some private class members, to keep track of the stuff needed to
     * access the BerkeleyDB.
     */
    private static boolean isReady = false;
    private static String bdbEnvHomeName = null;
    private static String bdbDatabaseName = null;
    private static EnvironmentConfig bdbEnvCfg = null;
    private static Environment bdbEnv = null;
    private static DatabaseConfig bdbDatabaseCfg = null;
    private static Database bdbDatabase = null;
    private static Transaction bdbTransaction = null;

    /* This is the BerkeleyDB key prefix.  For LHDRP processing, it will be
     * "LHDRP-".  For non-LHDRP processing, it will be "nonLHDRP-".  The
     * value to use will be picked up from our property file.
     */
    private static String keyPrefix = null;

    /* Some constants we'll use.  */
    private static final String UNASSIGNED = "UNASSIGNED-";
    private static final String MIN = "min";
    private static final String MAX = "max";

    /* The name of the resource holding our properties.  */
    private static final String PROPERTIES = "LHDRPassoc.properties";

    /* The properties loaded from the above resource.  */
    private static Properties props;

    /* The name of the properties that identify the path name of the
     * environment directory for our BerkeleyDB, and the name of the
     * database within it.
     */
    private static final String ENVLOCATION =
	"LHDRP.LHDRPassoc.BerkeleyDB.EnvHomeName";
    private static final String BDBNAME =
	"LHDRP.LHDRPassoc.BerkeleyDB.DatabaseName";
    private static final String KEYPREFIX = "LHDRP.LHDRPassoc.keyPrefix";

    /* Provide a command line interface that can be used to maintain
     * the contents of the BerkeleyDB.  (See the comment block above
     * for information on how to use this interface.)
     */
    public static void main(String[ ] arg)
	throws Exception
	{
	String operationType = null;

	/* Array of operation type names.  (For each entry in this array,
	 * be sure to define a "public static void" method with name
	 * "xxxOperation" [e.g., "setOperation" for "set"] which takes
	 * an array of strings as its [singleton] parameter.)
	 */
	String[ ] opTypes = {"create", "dump", "set", "get", "delete",
	    "lookup", "load", "unassigned"};
	int i, opTypeNdx;
	Method opMethod;

	/* Make sure that the user gave us an operation type.  */
	if ((arg.length < 1) || (arg[0].length( ) == 0)) {
	    System.err.println("LHDRPassoc/main:  this command requires at " +
		"least one command line parameter");
	    System.exit(1);
	    }

	/* Make sure it's in the list.  */
	opTypeNdx = -1;
	for (i = 0; i < opTypes.length; i++) {
	    /* If the first command line parameter doesn't match the first
	     * few characters of this operation type, ignore this operation
	     * type.
	     */
	    if (arg[0].length( ) > opTypes[i].length( )) continue;
	    if (! opTypes[i].substring(0, arg[0].length( )).
		equalsIgnoreCase(arg[0])) continue;

	    /* We have a match.  If we have a previous match, then this
	     * abbreviation is not ambiguous.
	     */
	    if (opTypeNdx >= 0) {
		System.err.println("LHDRPassoc/main:  operation type \"" +
		    arg[0] + "\" is not an unambiguous abbreviation - " +
		    "it matches \"" + opTypes[opTypeNdx] + "\" and \"" +
		    opTypes[i] + "\"");
		System.exit(1);
		}

	    /* We have found a new match.  Save it.  */
	    opTypeNdx = i;
	    }

	/* If we didn't find a match, complain.  */
	if (opTypeNdx < 0) {
	    System.err.println("LHDRPassoc/main:  operation type \"" + arg[0] +
		"\" is not recognized");
	    System.exit(1);
	    }

	/* Find the method in this class that handles it.  Convert operation
	 * type name "xxx" to method name "xxxOperation".
	 */
	opMethod = LHDRPassoc.class.getMethod(
	    opTypes[opTypeNdx] + "Operation", new Class[ ] { String[ ].class });

	/* Invoke it.  If it returns, then we'll assume everything went OK,
	 * and we'll exit with code 0.
	 */
	opMethod.invoke(null, new Object[ ] { arg });
	System.exit(0);
	}

    /* The "create" operation.  */
    public static void createOperation(String[ ] arg)
	throws Exception
	{
	/* No additional command line parameters are examined.  */
	if (arg.length > 1)
	    System.err.println("LHDRPassoc/create:  ignoring all but the " +
		"first command line parameter");

	/* Everything we need to do is done by the "initializeBerkeleyDB( )"
	 * method, when we specify "shouldCreate".
	 */
	initializeBerkeleyDB(true, false);
	return;
	}

    /* The "set" operation.  */
    public static void setOperation(String[ ] arg)
	throws Exception
	{
	DatabaseEntry bdbKey = null;
	DatabaseEntry bdbData = null;

	/* Check command line parameters.  */
	if ((arg.length < 3) || (arg[1].length( ) == 0) ||
	    (arg[2].length( ) == 0)) {
	    System.err.println("LHDRPassoc/set:  \"set\" requires 3 command " +
		"line parameters, \"set\", the key, and the data");
	    System.exit(1);
	    }
	if (arg.length > 3)
	    System.err.println("LHDRPassoc/set:  ignoring all but the first " +
		"3 command line parameters");

	/* Make sure that there is no white space in the key.  */
	if ((arg[1].indexOf(" ") >= 0) ||
	    (arg[1].indexOf("\n") >= 0) ||
	    (arg[1].indexOf("\t") >= 0)) {
	    System.err.println("LHDRPassoc/set:  the key (\"" + arg[1] +
		"\") contains a white space character (a blank, a tab, or " +
		"a line feed)");
	    System.exit(1);
	    }

	/* Set up the BerkeleyDB connection.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* Create the key and the data.  */
	bdbKey = new DatabaseEntry(arg[1].getBytes("UTF-8"));
	bdbData = new DatabaseEntry(arg[2].getBytes("UTF-8"));

	/* Do the "set", and check on its status.  (Shouldn't neeed a
	 * transaction, since this is all we're doing.)
	 */
	if (bdbDatabase.put(null, bdbKey, bdbData) == OperationStatus.SUCCESS)
	    System.out.println("LHDRPassoc/set:  set successful");
	else
	    System.out.println("LHDRPassoc/set:  set failed");

	return;
	}

    /* The "get" operation.  */
    public static void getOperation(String[ ] arg)
	throws Exception
	{
	DatabaseEntry bdbKey = null;
	DatabaseEntry bdbData = null;

	/* Check command line parameters.  */
	if ((arg.length < 2) || (arg[1].length( ) == 0)) {
	    System.err.println("LHDRPassoc/get:  \"get\" requires 2 command " +
		"line parameters, \"get\" and the key");
	    System.exit(1);
	    }
	if (arg.length > 2)
	    System.err.println("LHDRPassoc/get:  ignoring all but the first " +
		"2 command line parameters");

	/* Set up the BerkeleyDB connection.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* Create the key and an empty data receptacle.  */
	bdbKey = new DatabaseEntry(arg[1].getBytes("UTF-8"));
	bdbData = new DatabaseEntry( );

	/* Do the "get", and check on its status.  (Shouldn't neeed a
	 * transaction, since this is all we're doing.)
	 */
	if (bdbDatabase.get(null, bdbKey, bdbData, null) ==
	    OperationStatus.SUCCESS) {
	    /* Recreate the data string.  */
	    byte[ ] byteData = bdbData.getData( );
	    String stringData = new String(byteData, "UTF-8");
	    System.out.println("LHDRPassoc/get:  key \"" + arg[1] + "\" => " +
		"data \"" + stringData + "\"");
	    }
	else {
	    System.out.println("LHDRPassoc/get:  no data found for key " +
		"\"" + arg[1] + "\"");
	    }

	return;
	}

    /* The "delete" operation.  */
    public static void deleteOperation(String[ ] arg)
	throws Exception
	{
	DatabaseEntry bdbKey = null;
	OperationStatus opStat;

	/* Check command line parameters.  */
	if ((arg.length < 2) || (arg[1].length( ) == 0)) {
	    System.err.println("LHDRPassoc/delete:  \"delete\" requires 2 " +
		"command line parameters, \"delete\" and the key");
	    System.exit(1);
	    }
	if (arg.length > 2)
	    System.err.println("LHDRPassoc/delete:  ignoring all but the " +
		"first 2 command line parameters");

	/* Set up the BerkeleyDB connection.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* Create the key.  */
	bdbKey = new DatabaseEntry(arg[1].getBytes("UTF-8"));

	/* Do the operation.  */
	opStat = bdbDatabase.delete(null, bdbKey);
	if (opStat == OperationStatus.NOTFOUND)
	    System.out.println("LHDRPassoc/delete:  nothing to delete for " +
		"key " + "\"" + arg[1] + "\"");
	else
	if (opStat == OperationStatus.SUCCESS)
	    System.out.println("LHDRPassoc/delete:  deletion successful");
	else
	    System.out.println("LHDRPassoc/delete:  deletion unsuccessful");

	return;
	}

    /* The "dump" operation.  */
    public static void dumpOperation(String[ ] arg)
	throws Exception
	{
	PrintWriter output;
	Cursor dbdIter;
	DatabaseEntry bdbKey, bdbData;
	String stringKey, stringData, dumpLine;

	/* Check command line parameters.  */
	if ((arg.length < 2) || (arg[1].length( ) == 0)) {
	    System.err.println("LHDRPassoc/dump:  \"dump\" requires 2 " +
		"command line parameters, \"dump\" and the output file");
	    System.exit(1);
	    }
	if (arg.length > 2)
	    System.err.println("LHDRPassoc/dump:  ignoring all but the first " +
		"2 command line parameters");

	/* Prepare the output file.  */
	if (arg[1].equals("-"))
	    output = null;
	else
	    output = new PrintWriter(new BufferedWriter(new
		OutputStreamWriter(new FileOutputStream(arg[1]))));

	/* Set up the BerkeleyDB connection.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* Open a cursor.  Iterate over the entire database.  */
	dbdIter = bdbDatabase.openCursor(null, null);
	bdbKey = new DatabaseEntry( );
	bdbData = new DatabaseEntry( );
	while(dbdIter.getNext(bdbKey, bdbData, null) ==
	    OperationStatus.SUCCESS) {
	    stringKey = new String(bdbKey.getData( ), "UTF-8");
	    stringData = new String(bdbData.getData( ), "UTF-8");

	    /* Because of the assumption that there is no blank in any
	     * key, putting a blank at the end of the key on the way out
	     * will allow us to find the end of the key on the way back
	     * in.
	     */
	    dumpLine = stringKey + " " + stringData;

	    /* Write to the file or to STDOUT.  */
	    if (output == null)
		System.out.println(dumpLine);
	    else
		output.println(dumpLine);
	    }

	/* Close the cursor.  */
	dbdIter.close( );

	/* If we opened an output file, close it now.  */
	if (output != null)
	    output.close( );

	return;
	}

    /* The "lookup" operation.  (Use the method that the XSLT will use.)  */
    public static void lookupOperation(String[ ] arg)
	throws Exception
	{
	String results;

	/* Check command line parameters.  */
	if ((arg.length < 2) || (arg[0].length( ) == 0) ||
	    (arg[1].length( ) == 0)) {
	    System.err.println("LHDRPassoc/lookup:  \"lookup\" requires 2 " +
		"command line parameters, \"lookup\" and the LHDRP local id");
	    System.exit(1);
	    }
	if (arg.length > 2)
	    System.err.println("LHDRPassoc/lookup:  ignoring all but the " +
		"first 2 command line parameters");

	/* Do the lookup that the XSLT will do.  */
	results = getAssoc(arg[1]);

	/* Display the results.  */
	System.out.println("LHDRPassoc/lookup:  \"" + arg[1] + "\" is " +
	    "associated with \"" + results + "\"");
	return;
	}

    /* The "load" operation.  */
    public static void loadOperation(String[ ] arg)
	throws Exception
	{
	BufferedReader input;
	DatabaseEntry bdbKey, bdbData;
	String stringKey, stringData, loadLine;
	int lineNo, i;

	/* Check command line parameters.  */
	if ((arg.length < 2) || (arg[1].length( ) == 0)) {
	    System.err.println("LHDRPassoc/load:  \"load\" requires 2 " +
		"command line parameters, \"load\" and the input file");
	    System.exit(1);
	    }
	if (arg.length > 2)
	    System.err.println("LHDRPassoc/load:  ignoring all but the first " +
		"2 command line parameters");

	/* Prepare the input file.  */
	if (arg[1].equals("-"))
	    input = new BufferedReader(new InputStreamReader(System.in));
	else
	    input = new BufferedReader(new InputStreamReader(new
		FileInputStream(arg[1])));

	/* Set up the BerkeleyDB connection.  Request database truncation.  */
	if (! isReady) initializeBerkeleyDB(false, true);

	/* Read all the lines, and insert them into the database.  Since
	 * this command can be repeated, don't both with transactions.
	 * Auto-commit each addition.
	 */
	lineNo = 0;
	while ((loadLine = input.readLine( )) != null) {
	    lineNo++;

	    /* Make sure the line is not of length zero.  */
	    if (loadLine.length( ) == 0) {
		System.err.println("LHDRPassoc/load:  line number " + lineNo +
		    " in file \"" + arg[1] + "\" is empty");
		input.close( );
		System.exit(1);
		}
	
	    /* Find the space that separates the key and the value.  */
	    i = loadLine.indexOf(' ');

	    /* If there is no blank, it's an error.  */
	    if (i < 0) {
		System.err.println("LHDRPassoc/load:  line number " + lineNo +
		    " in file \"" + arg[1] + "\" does not contain a blank");
		input.close( );
		System.exit(1);
		}

	    /* Make sure both the key and the value are of non-zero length.  */
	    if (i == 0) {
		System.err.println("LHDRPassoc/load:  line number " + lineNo +
		    " in file \"" + arg[1] + "\" has a blank in the first " +
		    "column, meaning that the key is of length zero");
		input.close( );
		System.exit(1);
		}
	    if (i == (loadLine.length( ) - 1)) {
		System.err.println("LHDRPassoc/load:  line number " + lineNo +
		    " in file \"" + arg[1] + "\" has nothing after the first " +
		    "blank, meaning that the data is of length zero");
		input.close( );
		System.exit(1);
		}

	    /* With the above checks, we shouldn't cause any
	     * index-out-of-bounds exceptions, when we extract the key and
	     * the data.
	     */
	    stringKey = loadLine.substring(0, i);
	    stringData = loadLine.substring(i + 1, loadLine.length( ));

	    /* Convert the key and data into what "set" needs.  */
	    bdbKey = new DatabaseEntry(stringKey.getBytes("UTF-8"));
	    bdbData = new DatabaseEntry(stringData.getBytes("UTF-8"));

	    /* Do the "set", and check on its status.  If it didn't go well,
	     * complain.
	     */
	    if (bdbDatabase.put(null, bdbKey, bdbData) !=
		OperationStatus.SUCCESS) {
		System.err.println("LHDRPassoc/load:  for line number " +
		    lineNo + " in file \"" + arg[1] + "\" (key \"" + stringKey +
		    "\", data \"" + stringData + "\"), the database \"set\" " +
		    "failed");
		input.close( );
		System.exit(1);
		}
	    }

	/* Close the input file.  */
	input.close( );

	return;
	}

    /* The "unassigned" operation.  */
    public static void unassignedOperation(String[ ] arg)
	throws Exception
	{
	String stringMinUnassignedKey, stringMaxUnassignedKey;
	DatabaseEntry bdbMinUnassignedKey, bdbMaxUnassignedKey;
	String stringMinUnassigned, stringMaxUnassigned;
	int intMinUnassigned, intMaxUnassigned;
	String unassignedKey, unassignedValue;
	DatabaseEntry bdbUnassignedKey, bdbUnassignedValue;
	byte[ ] byteData;
	int i;

	/* Check command line parameters.  */
	if (arg.length < 2) {
	    System.err.println("LHDRPassoc/unassigned:  \"unassigned\" " +
		"requires at least 2 command line parameters, \"unassigned\" " +
		"and one new unassigned ARK number to add");
	    System.exit(1);
	    }
	for (i = 1; i < arg.length; i++)
	    if (arg[i].length( ) == 0) {
		System.err.println("LHDRPassoc/unassigned:  the length of " +
		    "the value of command line parameter number " + (i + 1) +
		    " is zero");
		System.exit(1);
		}

	/* Set up the BerkeleyDB connection.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* We should do this all in a transaction.  */
	bdbTransaction = bdbEnv.beginTransaction(null, null);

	/* Fetch the "UNASSIGNED-min" and "UNASSIGNED-max" values.  They
	 * might not be present.  Either they're both present and valid
	 * (WRT each other), or neither is present.  (We'll use a negative
	 * integer if the value is not present.)
	 */
	intMinUnassigned = -1;
	stringMinUnassignedKey = UNASSIGNED + MIN;
	stringMinUnassigned = null;
	bdbMinUnassignedKey = new DatabaseEntry(stringMinUnassignedKey.
	    getBytes("UTF-8"));
	bdbUnassignedValue = new DatabaseEntry( );
	if (bdbDatabase.get(bdbTransaction, bdbMinUnassignedKey,
	    bdbUnassignedValue, null) == OperationStatus.SUCCESS) {
	    byteData = bdbUnassignedValue.getData( );
	    stringMinUnassigned = new String(byteData, "UTF-8");
	    try {
		intMinUnassigned = Integer.parseInt(stringMinUnassigned);
		}
	    catch (Exception e) {
		bdbTransaction.commit( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKS because key \"" +
		    stringMinUnassignedKey + "\" has value \"" +
		    stringMinUnassigned + "\", which is not numeric " +
		    "(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		    "environment \"" + bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    if (intMinUnassigned < 0) {
		bdbTransaction.commit( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKS because key \"" +
		    stringMinUnassignedKey + "\" has value \"" +
		    stringMinUnassigned + "\", which is negative (BerkeleyDB " +
		    "database \"" + bdbDatabaseName + "\" in environment \"" +
		    bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    }
	intMaxUnassigned = -1;
	stringMaxUnassignedKey = UNASSIGNED + MAX;
	stringMaxUnassigned = null;
	bdbMaxUnassignedKey = new DatabaseEntry(stringMaxUnassignedKey.
	    getBytes("UTF-8"));
	bdbUnassignedValue = new DatabaseEntry( );
	if (bdbDatabase.get(bdbTransaction, bdbMaxUnassignedKey,
	    bdbUnassignedValue, null) == OperationStatus.SUCCESS) {
	    byteData = bdbUnassignedValue.getData( );
	    stringMaxUnassigned = new String(byteData, "UTF-8");
	    try {
		intMaxUnassigned = Integer.parseInt(stringMaxUnassigned);
		}
	    catch (Exception e) {
		bdbTransaction.commit( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKS because key \"" +
		    stringMaxUnassignedKey + "\" has value \"" +
		    stringMaxUnassigned + "\", which is not numeric " +
		    "(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		    "environment \"" + bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    if (intMaxUnassigned < 0) {
		bdbTransaction.commit( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKS because key \"" +
		    stringMaxUnassignedKey + "\" has value \"" +
		    stringMaxUnassigned + "\", which is negative (BerkeleyDB " +
		    "database \"" + bdbDatabaseName + "\" in environment \"" +
		    bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    }

	/* If one is present, but the other is not, that's a problem.  */
	if ((intMinUnassigned >= 0) && (intMaxUnassigned < 0)) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    System.err.println("LHDRPassoc/unassigned:  unable to load new " +
		"unassigned ARKS because a value for key \"" +
		stringMinUnassignedKey + "\" is present, but a value for " +
		"key \"" + stringMaxUnassignedKey + "\" is absent " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")");
	    System.exit(1);
	    }
	if ((intMinUnassigned < 0) && (intMaxUnassigned >= 0)) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    System.err.println("LHDRPassoc/unassigned:  unable to load new " +
		"unassigned ARKS because a value for key \"" +
		stringMaxUnassignedKey + "\" is present, but a value for " +
		"key \"" + stringMinUnassignedKey + "\" is absent " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")");
	    System.exit(1);
	    }

	/* Either they're both absent, or they're both present.  */
	if (intMinUnassigned < 0) {
	    /* They are both missing.  We'll install a new "UNASSIGNED-min"
	     * value as 1, and a new "UNASSIGNED-max" value, based on the
	     * count of ARK numbers we're loading.
	     */
	    intMinUnassigned = 0;
	    }
	else {
	    /* They are both present.  Make sure that the minimum is less
	     * than or equal to the maximum.
	     */
	    if (intMinUnassigned > intMaxUnassigned) {
		bdbTransaction.commit( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKs because key \"" +
		    stringMinUnassignedKey + "\" has value \"" +
		    stringMinUnassigned + "\" and key \"" +
		    stringMaxUnassignedKey + "\" has value \"" +
		    stringMaxUnassigned + "\", implying that no unassigned " +
		    "ARK numbers exist " + "(BerkeleyDB database \"" +
		    bdbDatabaseName + "\" in environment \"" +
		    bdbEnvHomeName + "\")");
		System.exit(1);
		}

	    /* Set it so that the next number will be one more than the
	     * current maximum.
	     */
	    intMinUnassigned = intMaxUnassigned;

	    /* No need to set the value of "UNASSIGNED-min" when we're done.  */
	    bdbMinUnassignedKey = null;
	    }

	/* For each new ARK number, load it.  */
	for (i = 1; i < arg.length; i++) {
	    /* Increment the number we'll use in the key.  */
	    intMinUnassigned++;

	    /* Create the new key and value.  */
	    unassignedKey = UNASSIGNED + Integer.toString(intMinUnassigned);
	    bdbUnassignedKey = new DatabaseEntry(unassignedKey.
		getBytes("UTF-8"));
	    bdbUnassignedValue = new DatabaseEntry(arg[i].getBytes("UTF-8"));

	    /* Add them to the database.  */
	    if (bdbDatabase.put(bdbTransaction, bdbUnassignedKey,
		bdbUnassignedValue) != OperationStatus.SUCCESS) {
		bdbTransaction.abort( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKs because of failure to store key \"" +
		    unassignedKey + "\" with value \"" + arg[i] +
		    "\" (BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		    "environment \"" + bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    }

	/* Set "UNASSIGNED-min" to "1", if we were supposed to do that.  */
	if (bdbMinUnassignedKey != null) {
	    bdbUnassignedValue = new DatabaseEntry("1".getBytes("UTF-8"));
	    if (bdbDatabase.put(bdbTransaction, bdbMinUnassignedKey,
		bdbUnassignedValue) != OperationStatus.SUCCESS) {
		bdbTransaction.abort( );
		bdbTransaction = null;
		System.err.println("LHDRPassoc/unassigned:  unable to load " +
		    "new unassigned ARKs because of failure to store key \"" +
		    stringMinUnassignedKey + "\" with value \"1\" " +
		    "(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		    "environment \"" + bdbEnvHomeName + "\")");
		System.exit(1);
		}
	    }

	/* Set the new value for "UNASSIGNED-max".  */
	stringMaxUnassigned = Integer.toString(intMinUnassigned);
	bdbUnassignedValue = new DatabaseEntry(stringMaxUnassigned.
	    getBytes("UTF-8"));
	if (bdbDatabase.put(bdbTransaction, bdbMaxUnassignedKey,
	    bdbUnassignedValue) != OperationStatus.SUCCESS) {
	    bdbTransaction.abort( );
	    bdbTransaction = null;
	    System.err.println("LHDRPassoc/unassigned:  unable to load new " +
		"unassigned ARKs because of failure to store key \"" +
		stringMaxUnassignedKey + "\" with value \"" +
		stringMaxUnassigned + "\" (BerkeleyDB database \"" +
		bdbDatabaseName + "\" in environment \"" + bdbEnvHomeName +
		"\")");
	    System.exit(1);
	    }

	/* All the adding went well.  Commit the transaction.  */
	bdbTransaction.commit( );
	bdbTransaction = null;

	return;
	}

    /* Static method to return the association.  */
    public static String getAssoc(String searchLocalIdParam)
	throws Exception
	{
	String searchLocalId;
	String stringMinUnassignedKey, stringMaxUnassignedKey;
	DatabaseEntry bdbMinUnassignedKey, bdbMaxUnassignedKey;
	DatabaseEntry bdbLocalIdKey, bdbData;
	byte[ ] byteData;
	String stringMinUnassigned, stringMaxUnassigned;
	int intMinUnassigned, intMaxUnassigned;
	String unassignedKey;
	DatabaseEntry bdbUnassignedKey;
	String unassignedARK;

	/* The local id is case insensitive.  Convert it to lower case.  */
	searchLocalId = searchLocalIdParam.toLowerCase( );

	/* We expect no blanks, newlines, or tabs in the search string.
	 * If one is present, complain.
	 */
	if ((searchLocalId.indexOf(" ") >= 0) ||
	    (searchLocalId.indexOf("\n") >= 0) ||
	    (searchLocalId.indexOf("\t") >= 0))
	    throw new Exception("LHDRPassoc/getAssoc:  the local id to " +
		"search for (\"" + searchLocalId + "\") contains a white " +
		"space character (a blank, a tab, or a line feed)");

	/* If we haven't already connected to the BerkeleyDB, do so now.  */
	if (! isReady) initializeBerkeleyDB(false, false);

	/* Set up the key and an empty data receptacle.  */
	bdbLocalIdKey = new DatabaseEntry((new String(keyPrefix +
	    searchLocalId)).getBytes("UTF-8"));
	bdbData = new DatabaseEntry( );

	/* Do the "get", and check on its status.  (I think that using a
	 * transaction for a "get" works only when the record to be gotten
	 * already exists, e.g., a read/modify/write cycle.  In our case,
	 * we only want to modify the database if the record to be gotten
	 * does not exist.  But it can't hurt to use a transaction in that
	 * case too.)
	 */
	bdbTransaction = bdbEnv.beginTransaction(null, null);
	if (bdbDatabase.get(bdbTransaction, bdbLocalIdKey, bdbData, null) ==
	    OperationStatus.SUCCESS) {
	    /* Terminate the transaction.  */
	    bdbTransaction.commit( );
	    bdbTransaction = null;

	    /* Recreate the results data string, and return it.  */
	    byteData = bdbData.getData( );
	    return(new String(byteData, "UTF-8"));
	    }

	/* There is no entry for the given key.  We want to assign a new
	 * ARK number for this, and record it.  A number of changes to
	 * the database will be necessary for this assignment:  the change
	 * to the unassigned minimum number, the deletion of the unassigned
	 * ARK, and the addition of a key/value for this LHDRP local id.
	 * Do all these in a transaction.  In the transation that we
	 * started for the initial "get".
	 */
	stringMinUnassignedKey = UNASSIGNED + MIN;
	bdbMinUnassignedKey = new DatabaseEntry(stringMinUnassignedKey.
	    getBytes("UTF-8"));
	bdbData = new DatabaseEntry( );
	if (bdbDatabase.get(bdbTransaction, bdbMinUnassignedKey, bdbData,
	    null) != OperationStatus.SUCCESS) {
	    /* Terminate the transaction.  */
	    bdbTransaction.commit( );
	    bdbTransaction = null;

	    /* Cannot assign an ARK number, because we won't know where to
	     * find it.
	     */
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + stringMinUnassignedKey + "\" does not " +
		"exist in BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\"");
	    }

	/* Get the value of the minimum number.  */
	byteData = bdbData.getData( );
	stringMinUnassigned = new String(byteData, "UTF-8");
	try {
	    intMinUnassigned = Integer.parseInt(stringMinUnassigned);
	    }
	catch (Exception e) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId +
		"\" because key \"" + stringMinUnassignedKey + "\" has value " +
		"\"" + stringMinUnassigned + "\", which is not numeric " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")" +
		e.getMessage( ));
	    }
	/* Make sure it's not negative.  */
	if (intMinUnassigned < 0) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId +
		"\" because key \"" + stringMinUnassignedKey + "\" has value " +
		"\"" + stringMinUnassigned + "\", which is negative " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")");
	    }

	/* Do the same for the maximum number.  */
	stringMaxUnassignedKey = UNASSIGNED + MAX;
	bdbMaxUnassignedKey = new DatabaseEntry(stringMaxUnassignedKey.
	    getBytes("UTF-8"));
	bdbData = new DatabaseEntry( );
	if (bdbDatabase.get(bdbTransaction, bdbMaxUnassignedKey, bdbData,
	    null) != OperationStatus.SUCCESS) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + stringMaxUnassignedKey + "\" does not " +
		"exist in BerkeleyDB database \"" + bdbDatabaseName +
		"\" in environment \"" + bdbEnvHomeName + "\"");
	    }
	byteData = bdbData.getData( );
	stringMaxUnassigned = new String(byteData, "UTF-8");
	try {
	    intMaxUnassigned = Integer.parseInt(stringMaxUnassigned);
	    }
	catch (Exception e) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + stringMaxUnassignedKey + "\" has value " +
		"\"" + stringMaxUnassigned + "\", which is not numeric " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")" +
		e.getMessage( ));
	    }
	if (intMaxUnassigned < 0) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + stringMaxUnassignedKey + "\" has value " +
		"\"" + stringMaxUnassigned + "\", which is negative " +
		"(BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\")");
	    }

	/* Make sure that the minimum is less than or equal to the maximum.  */
	if (intMinUnassigned > intMaxUnassigned) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + stringMinUnassignedKey + "\" has value " +
		"\"" + stringMinUnassigned + "\" and key \"" +
		stringMaxUnassignedKey + "\" has value \"" +
		stringMaxUnassigned + "\", implying that no unassigned ARK " +
		"numbers exist " + "(BerkeleyDB database \"" + bdbDatabaseName +
		"\" in environment \"" + bdbEnvHomeName + "\")");
	    }

	/* We should now be able to find the next unassigned ARK number.  */
	unassignedKey = UNASSIGNED + Integer.toString(intMinUnassigned);
	bdbUnassignedKey = new DatabaseEntry(unassignedKey.getBytes("UTF-8"));
	bdbData = new DatabaseEntry( );
	if (bdbDatabase.get(bdbTransaction, bdbUnassignedKey, bdbData,
	    null) != OperationStatus.SUCCESS) {
	    bdbTransaction.commit( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because key \"" + unassignedKey + "\" does not exist in " +
		"BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\"");
	    }
	byteData = bdbData.getData( );
	unassignedARK = new String(byteData, "UTF-8");

	/* Delete the ARK number we're about to assign.  */
	if (bdbDatabase.delete(bdbTransaction, bdbUnassignedKey) !=
	    OperationStatus.SUCCESS) {
	    bdbTransaction.abort( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because deletion of key \"" + unassignedKey + "\" failed in " +
		"BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		"environment \"" + bdbEnvHomeName + "\"");
	    }

	/* Update the "UNASSIGNED-min" number to reflect this assignment.
	 * If the new "UNASSIGNED-min" number exceeds the "UNASSIGNED-max"
	 * number, then just delete both of them, because it means that
	 * we don't have any more unassigned ARK numbers in the database.
	 */
	intMinUnassigned++;
	if (intMinUnassigned > intMaxUnassigned) {
	    if (bdbDatabase.delete(bdbTransaction, bdbMinUnassignedKey) !=
		OperationStatus.SUCCESS) {
		bdbTransaction.abort( );
		bdbTransaction = null;
		throw new Exception("LHDRPassoc/getAssoc:  unable to assign " +
		    "a new ARK number for local id \"" + searchLocalId + "\" " +
		    "because deletion of key \"" + stringMinUnassignedKey +
		    "\" failed in BerkeleyDB database \"" + bdbDatabaseName +
		    "\" in environment \"" + bdbEnvHomeName + "\"");
		}
	    if (bdbDatabase.delete(bdbTransaction, bdbMaxUnassignedKey) !=
		OperationStatus.SUCCESS) {
		bdbTransaction.abort( );
		bdbTransaction = null;
		throw new Exception("LHDRPassoc/getAssoc:  unable to assign " +
		    "a new ARK number for local id \"" + searchLocalId + "\" " +
		    "because deletion of key \"" + stringMaxUnassignedKey +
		    "\" failed in BerkeleyDB database \"" + bdbDatabaseName +
		    "\" in environment \"" + bdbEnvHomeName + "\"");
		}
	    }
	else {
	    /* We should not delete the min and max, because there are
	     * numbers still left.  Just update the minimum number.
	     */
	    bdbData = new DatabaseEntry(Integer.toString(intMinUnassigned).
		getBytes("UTF-8"));
	    if (bdbDatabase.put(bdbTransaction, bdbMinUnassignedKey, bdbData) !=
		OperationStatus.SUCCESS) {
		bdbTransaction.abort( );
		bdbTransaction = null;
		throw new Exception("LHDRPassoc/getAssoc:  unable to assign " +
		    "a new ARK number for local id \"" + searchLocalId + "\" " +
		    "because update of value of key \"" + unassignedKey +
		    "\" failed in BerkeleyDB database \"" + bdbDatabaseName +
		    "\" in environment \"" + bdbEnvHomeName + "\"");
		}
	    }

	/* If the unassigned ARK number doesn't start with "ark:/", then
	 * prepend that prefix.
	 */
	if ((unassignedARK.length( ) < 5) || (! unassignedARK.substring(0, 5).
	    equals("ark:/")))
	    unassignedARK = "ark:/" + unassignedARK;

	/* Assign the new ARK number to the local id.  */
	bdbData = new DatabaseEntry(unassignedARK.getBytes("UTF-8"));
	if (bdbDatabase.put(bdbTransaction, bdbLocalIdKey, bdbData) !=
	    OperationStatus.SUCCESS) {
	    bdbTransaction.abort( );
	    bdbTransaction = null;
	    throw new Exception("LHDRPassoc/getAssoc:  unable to assign a " +
		"new ARK number for local id \"" + searchLocalId + "\" " +
		"because saving the new value for it failed in BerkeleyDB " +
		"database \"" + bdbDatabaseName + "\" in environment " +
		"\"" + bdbEnvHomeName + "\"");
	    }

	/* Everything went well.  Commit the transaction.  */
	bdbTransaction.commit( );
	bdbTransaction = null;

	/* Return the value we assigned.  */
	return(unassignedARK);
	}

    /* Method to connect to an existing BerkeleyDB.  */
    private static void initializeBerkeleyDB(boolean shouldCreate,
	boolean shouldTruncate)
	throws Exception
	{
	File envHome;

	/* Make sure that we get control when the run is over, so we
	 * can close the database and environment, to make sure that
	 * any changes get written out.
	 */
	Runtime.getRuntime( ).addShutdownHook(new LHDRPassoc( ));

	/* Get the names of the environment and database.  */
	getEnvAndDbNames( );

	/* Ensure that the directory exists.  */
	envHome = new File(bdbEnvHomeName);
	if (! envHome.exists( ))
	    throw new Exception("LHDRPassoc/initializeBerkeleyDB:  " +
		"environment directory \"" + bdbEnvHomeName + "\" does not " +
		"exist");
	if (! envHome.isDirectory( ))
	    throw new Exception("LHDRPassoc/initializeBerkeleyDB:  " +
		"environment directory \"" + bdbEnvHomeName + "\" exists, " +
		"but is not a directory");

	/* Create a new environment object.  */
	bdbEnvCfg = new EnvironmentConfig( );
	if (shouldCreate)
	    bdbEnvCfg.setAllowCreate(true);
	bdbEnvCfg.setTransactional(true);
	bdbEnv = new Environment(envHome, bdbEnvCfg);

	/* If the caller so requests, empty the database before we start.  */
	if (shouldTruncate)
	    bdbEnv.truncateDatabase(null, bdbDatabaseName, false);

	/* Create the database object.  */
	bdbDatabaseCfg = new DatabaseConfig( );
	if (shouldCreate) {
	    bdbDatabaseCfg.setAllowCreate(true);
	    bdbDatabaseCfg.setExclusiveCreate(true);
	    }
	bdbDatabaseCfg.setTransactional(true);
	bdbDatabase = bdbEnv.openDatabase(null, bdbDatabaseName,
	    bdbDatabaseCfg);

	/* Say that the bdb is ready to use.  */
	isReady = true;
	}

    /* Instance method which is started when the run is over.  */
    public void run( ) {
	/* If we didn't get everything ready, there's nothing to do.  */
	if (! isReady) return;

	/* If there was a transaction active, abort it.  */
	if (bdbTransaction != null) {
	    try {
		bdbTransaction.abort( );
		}
	    catch (Exception e) {
		System.err.println("LHDRPassoc/run:  an error occured during " +
		    "the attempt to abort the active transaction on the " +
		    "BerkeleyDB database \"" + bdbDatabaseName + "\" in " +
		    "environment \"" + bdbEnvHomeName + "\":  " +
		    e.getMessage( ));
		}
	    bdbTransaction = null;
	    }

	/* Close the database.  */
	if (bdbDatabase != null) {
	    try {
		bdbDatabase.close( );
		}
	    catch (Exception e) {
		System.err.println("LHDRPassoc/run:  an error occured during " +
		    "the attempt to close the BerkeleyDB database " +
		    "\"" + bdbDatabaseName + "\" in environment " +
		    "\"" + bdbEnvHomeName + "\":  " + e.getMessage( ));
		}
	    bdbDatabase = null;
	    }

	/* Close the environment.  */
	if (bdbEnv != null) {
	    try {
		bdbEnv.cleanLog( );
		bdbEnv.close( );
		}
	    catch (Exception e) {
		System.err.println("LHDRPassoc/run:  an error occured during " +
		    "the attempt to close the BerkeleyDB environment " +
		    "\"" + bdbEnvHomeName + "\":  " + e.getMessage( ));
		}
	    bdbEnv = null;
	    }

	isReady = false;

	return;
	}

    /* Method that sets the name of the environment and the database.  */
    private static void getEnvAndDbNames( )
	throws Exception
	{
	InputStream propFile;

	/* Access the file that contains our properties.  */
	propFile = LHDRPassoc.class.getResourceAsStream(PROPERTIES);
	if (propFile == null)
	    throw new Exception("LHDRPassoc/getEnvAndDbNames:  unable to " +
		"locate class resource \"" + PROPERTIES + "\"");

	/* Load the properties there.  */
	props = new Properties( );
	props.load(propFile);

	/* Get the pathname to the environment directory, and the name of
	 * the BerkeleyDB within it.
	 */
	bdbEnvHomeName = props.getProperty(ENVLOCATION);
	if (bdbEnvHomeName == null)
	    throw new Exception("LHDRPassoc/getEnvAndDbNames:  unable to " +
		"locate property \"" + ENVLOCATION + "\" in class resource " +
		"\"" + PROPERTIES + "\"");
	bdbDatabaseName = props.getProperty(BDBNAME);
	if (bdbDatabaseName == null)
	    throw new Exception("LHDRPassoc/getEnvAndDbNames:  unable to " +
		"locate property \"" + BDBNAME + "\" in class resource \"" +
		PROPERTIES + "\"");

	/* Get the key prefix we should use for the local
	 * identifier "universe".
	 */
	keyPrefix = props.getProperty(KEYPREFIX);
	if (keyPrefix == null)
	    throw new Exception("LHDRPassoc/getEnvAndDbNames:  unable to " +
		"locate property \"" + KEYPREFIX + "\" in class resource \"" +
		PROPERTIES + "\"");

	return;
	}
    }
