/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2002,2008 Oracle.  All rights reserved.
 *
 * $Id: NullClassCatalog.java,v 1.17.2.3 2008/01/07 15:14:22 cwl Exp $
 */

package com.sleepycat.bind.serial.test;

import java.io.ObjectStreamClass;
import java.math.BigInteger;

import com.sleepycat.je.DatabaseException;
import com.sleepycat.bind.serial.ClassCatalog;

/**
 * NullCatalog is a dummy Catalog implementation that simply
 * returns large (8 byte) class IDs so that ObjectOutput
 * can be simulated when computing a serialized size.
 *
 * @author Mark Hayes
 */
class NullClassCatalog implements ClassCatalog {

    private long id = Long.MAX_VALUE;

    public void close()
        throws DatabaseException {
    }

    public byte[] getClassID(ObjectStreamClass classFormat)
        throws DatabaseException {

        return BigInteger.valueOf(id--).toByteArray();
    }

    public ObjectStreamClass getClassFormat(byte[] classID)
        throws DatabaseException, ClassNotFoundException {

        return null; // ObjectInput not supported
    }
}
