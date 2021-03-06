/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2002,2008 Oracle.  All rights reserved.
 *
 * $Id: TxnalEntry.java,v 1.4.2.3 2008/01/07 15:14:31 cwl Exp $
 */

package com.sleepycat.je.recovery.stepwise;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.sleepycat.bind.tuple.IntegerBinding;
import com.sleepycat.je.DatabaseEntry;

/*
 * A Transactional log entry should add put itself
 * into the not-yet-committed set.
 */

public class TxnalEntry extends LogEntryInfo {
    private long txnId;

    TxnalEntry(long lsn,
               int key,
               int data,
               long txnId) {
        super(lsn, key, data);
        this.txnId = txnId;
    }

    /* Implement this accordingly. For example, a LogEntryInfo which
     * represents a non-txnal LN record would add that key/data to the
     * expected set. A txnal delete LN record would delete the record
     * from the expecte set at commit time.
     */
    public void updateExpectedSet(Set useExpected,
                                  Map newUncommittedRecords,
                                  Map deletedUncommittedRecords) {
        DatabaseEntry keyEntry = new DatabaseEntry();
        DatabaseEntry dataEntry = new DatabaseEntry();

        IntegerBinding.intToEntry(key, keyEntry);
        IntegerBinding.intToEntry(data, dataEntry);

        Long mapKey = new Long(txnId);
        Set records = (Set) newUncommittedRecords.get(mapKey);
        if (records == null) {
            records = new HashSet();
            newUncommittedRecords.put(mapKey, records);
        }
        records.add(new TestData(keyEntry, dataEntry));
    }
}
