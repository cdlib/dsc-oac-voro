/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2002,2008 Oracle.  All rights reserved.
 *
 * $Id: TestDataBinding.java,v 1.24.2.2 2008/01/07 15:14:24 cwl Exp $
 */

package com.sleepycat.collections.test;

import com.sleepycat.bind.EntryBinding;
import com.sleepycat.je.DatabaseEntry;

/**
 * @author Mark Hayes
 */
class TestDataBinding implements EntryBinding {

    public Object entryToObject(DatabaseEntry data) {

        if (data.getSize() != 1) {
            throw new IllegalStateException("size=" + data.getSize());
        }
        byte val = data.getData()[data.getOffset()];
        return new Long(val);
    }

    public void objectToEntry(Object object, DatabaseEntry data) {

        byte val = ((Number) object).byteValue();
        data.setData(new byte[] { val }, 0, 1);
    }
}
