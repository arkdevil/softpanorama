//
// Table - Better Vector/Stack class
//

package iss.util;

import java.util.Stack;

public class Table extends Stack {

// Get 

  public Object get(int index) {
    return elementAt(index);
  }

  public int getInt(int index) {
    if (index < size()) {
      Object obj = elementAt(index);
      
      if (obj instanceof Integer)
        return ((Integer) obj).intValue();
      else
        return (new Integer(obj.toString())).intValue();
    }

    return 0;
  }

  public long getLong(int index) {
    if (index < size()) {
      Object obj = elementAt(index);

      if (obj instanceof Long)
        return ((Long) obj).longValue();
      else
        return (new Long(obj.toString())).longValue();
    }

    return 0;
  }

  public float getFloat(int index) {
    if (index < size()) {
      Object obj = elementAt(index);

      if (obj instanceof Float)
        return ((Float) obj).floatValue();
      else
        return (new Float(obj.toString())).floatValue();
    }

    return 0f;
  }

  public String getString(int index) {
    if (index < size())
      return elementAt(index).toString();

    return "";
  }

  public Table getTable(int index) {
    return (Table) elementAt(index);
  }

  public Hash getHash(int index) {
    return (Hash) elementAt(index);
  }

// Pop

  public int popInt() {
    Object obj = pop();

    if (obj instanceof Integer)
      return ((Integer) obj).intValue();
    else
      return (new Integer(obj.toString())).intValue();
  }

  public long popLong() {
    Object obj = pop();

    if (obj instanceof Long)
      return ((Long) obj).longValue();
    else
      return (new Long(obj.toString())).longValue();
  }

  public float popFloat() {
    Object obj = pop();

    if (obj instanceof Float)
      return ((Float) obj).floatValue();
    else
      return (new Float(obj.toString())).floatValue();
  }

  public String popString() {
    return pop().toString();
  }

  public Table popTable() {
    return (Table) pop();
  }

  public Hash popHash() {
    return (Hash) pop();
  }

// Add

  public Table add(Object obj) {
    addElement(obj);
    return this;
  }

  public Table add(int val) {
    addElement(new Integer(val));
    return this;
  }

  public Table add(long val) {
    addElement(new Long(val));
    return this;
  }

  public Table add(float val) {
    addElement(new Float(val));
    return this;
  }

// Add at

  public Table addAt(Object obj, int index) {
    insertElementAt(obj, index);
    return this;
  }

  public Table addAt(int val, int index) {
    insertElementAt(new Integer(val), index);
    return this;
  }

  public Table addAt(long val, int index) {
    insertElementAt(new Long(val), index);
    return this;
  }

  public Table addAt(float val, int index) {
    insertElementAt(new Float(val), index);
    return this;
  }

// Set

  public void set(Object obj, int index) {
    setElementAt(obj, index);
  }

  public void set(int val, int index) {
    setElementAt(new Integer(val), index);
  }

  public void set(long val, int index) {
    setElementAt(new Long(val), index);
  }

  public void set(float val, int index) {
    setElementAt(new Float(val), index);
  }

// Remove

  public boolean remove(Object obj) {
    return removeElement(obj);
  }

  public boolean remove(int val) {
    return removeElement(new Integer(val));
  }

  public boolean remove(long val) {
    return removeElement(new Long(val));
  }

  public boolean remove(float val) {
    return removeElement(new Float(val));
  }

// Remove at

  public Table removeAt(int index) {
    removeElementAt(index);
    return this;
  }

// Clear

  public Table clear() {
    removeAllElements();
    return this;
  }

// Get class name

  public String getClassName(int index) {
    if (index < size())
      return elementAt(index).getClass().getName();

    return "";
  }
}
