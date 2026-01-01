//
// Hash - Better Hashtable class
//

package iss.util;

import java.util.Hashtable;
import java.util.Enumeration;

public class Hash extends Hashtable {

// Get

  public final Object get(int key) {
    return get(new Integer(key));
  }

  public final int getInt(Object key) {
    Object obj = get(key);

    if (obj != null) {
      if (obj instanceof Integer)
        return ((Integer) obj).intValue();
      else
        return (new Integer(obj.toString())).intValue();
    }

    return 0;
  }

  public final int getInt(int key) {
    return getInt(new Integer(key));
  }

  public final long getLong(Object key) {
    Object obj = get(key);

    if (obj != null) {
      if (obj instanceof Long)
        return ((Long) obj).longValue();
      else
        return (new Long(obj.toString())).longValue();
    }

    return 0;
  }

  public final long getLong(int key) {
    return getLong(new Integer(key));
  } 

  public final float getFloat(Object key) {
    Object obj = get(key);

    if (obj != null) {
      if (obj instanceof Float)
        return ((Float) obj).floatValue();
      else
        return (new Float(obj.toString())).floatValue();
    }

    return 0f;
  }

  public final float getFloat(int key) {
    return getFloat(new Float(key));
  } 

  public final String getString(Object key) {
    Object obj = get(key);

    if (obj != null) 
      return obj.toString();

    return "";
  }

  public final String getString(int key) {
    return getString(new Integer(key));
  }

  public final Table getTable(Object key) {
    return (Table) get(key);
  }

  public final Table getTable(int key) {
    return (Table) get(new Integer(key));
  }

  public final Hash getHash(Object key) {
    return (Hash) get(key);
  }

  public final Hash getHash(int key) {
    return (Hash) get(new Integer(key));
  }

// Set

  public final void set(Object key, Object val) {
    put(key, val);
  }

  public final void set(Object key, int val) {
    put(key, new Integer(val));
  }

  public final void set(int key, Object val) {
    put(new Integer(key), val);
  }

  public final void set(int key, int val) {
    put(new Integer(key), new Integer(val));
  }

// Get class name

  public final String getClassName(Object key) {
    Object obj = get(key);

    if (obj != null)
      return obj.getClass().getName();

    return "";
  }

  public final String getClassName(int key) {
    return getClassName(new Integer(key));
  }

// Get all key names

  public final Table keyNames() {
    Table tb = new Table();
    Enumeration en = keys();

    while (en.hasMoreElements())
      tb.add(en.nextElement());

    return tb;
  } 
}
