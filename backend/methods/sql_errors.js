function getFriendlySqlError(error) {
  if (!error || typeof error !== "object") return "Unknown database error";

  const { code, errno, message = "", sqlMessage = "" } = error;
  const fullMessage = sqlMessage || message;
  let hint = "";

  switch (code) {
    case "ER_DUP_ENTRY": {
      const match = fullMessage.match(/Duplicate entry '(.+)' for key '(.+)'/);
      if (match) {
        const [, value, key] = match;
        hint = `The value '${value}' already exists for unique key '${key}'.`;
      }
      return "Duplicate entry. " + hint;
    }

    case "ER_DATA_TOO_LONG": {
      const match = fullMessage.match(/Data too long for column '(.+)'/);
      if (match) {
        hint = `Field '${match[1]}' received more characters than allowed.`;
      }
      return "Input too long. " + hint;
    }

    case "ER_BAD_NULL_ERROR": {
      const match = fullMessage.match(/Column '(.+)' cannot be null/);
      if (match) {
        hint = `Missing required field '${match[1]}'.`;
      }
      return "Required field is missing. " + hint;
    }

    case "ER_NO_REFERENCED_ROW_2":
    case "ER_ROW_IS_REFERENCED":
    case "ER_ROW_IS_REFERENCED_2": {
      const match = fullMessage.match(
        /FOREIGN KEY \(`(.+?)`\) REFERENCES `(.+?)`/
      );
      if (match) {
        const [, fk, refTable] = match;
        hint = `The field '${fk}' refers to data in '${refTable}' that does not exist or is still in use.`;
      }
      return "Cannot update/delete due to foreign key constraint. " + hint;
    }

    case "ER_TRUNCATED_WRONG_VALUE": {
      const match = fullMessage.match(
        /Incorrect (.+) value: '(.+)' for column '(.+)'/
      );
      if (match) {
        const [, type, value, field] = match;
        hint = `Expected a valid ${type} for field '${field}', but got '${value}'.`;
      }
      return "Invalid value format. " + hint;
    }

    case "ER_PARSE_ERROR":
    case "ER_SYNTAX_ERROR":
      return "SQL syntax error. Check your query.";

    case "ER_UNKNOWN_COLUMN": {
      const match = fullMessage.match(/Unknown column '(.+)' in '(.+)'/);
      if (match) {
        const [, column, context] = match;
        hint = `Column '${column}' not found in '${context}'.`;
      }
      return "Unknown column referenced in query. " + hint;
    }

    case "ER_DUP_FIELDNAME": {
      const match = fullMessage.match(/Duplicate column name '(.+)'/);
      if (match) {
        hint = `The column name '${match[1]}' is duplicated in the query.`;
      }
      return "Duplicate column name found in query. " + hint;
    }

    case "ER_TABLE_EXISTS_ERROR": {
      const match = fullMessage.match(/Table '(.+)' already exists/);
      if (match) {
        hint = `The table '${match[1]}' already exists in the database.`;
      }
      return "Table already exists. " + hint;
    }

    case "ER_BAD_DB_ERROR": {
      const match = fullMessage.match(/Unknown database '(.+)'/);
      if (match) {
        hint = `The database '${match[1]}' does not exist.`;
      }
      return "Unknown database. " + hint;
    }

    case "ER_ACCESS_DENIED_ERROR": {
      const match = fullMessage.match(/Access denied for user '(.+)'@'(.+)'/);
      if (match) {
        const [, user, host] = match;
        hint = `Access denied for user '${user}' from host '${host}'.`;
      }
      return "Access denied. " + hint;
    }

    case "ER_NO_DB_ERROR":
      return "No database selected. Please select a database before executing queries.";

    case "ER_CON_COUNT_ERROR":
      return "Too many connections. The database has reached its maximum connection limit.";

    case "ER_LOCK_WAIT_TIMEOUT":
      return "Lock wait timeout exceeded. A database lock is taking too long.";

    case "ER_LOCK_DEADLOCK":
      return "Deadlock detected. Retry the transaction.";

    case "ER_CANT_CREATE_TABLE": {
      const match = fullMessage.match(/Can't create table '(.+)'/);
      if (match) {
        hint = `Unable to create table '${match[1]}'. Check for existing constraints or permissions.`;
      }
      return "Cannot create table. " + hint;
    }

    case "ER_CANT_CREATE_DB": {
      const match = fullMessage.match(/Can't create database '(.+)'/);
      if (match) {
        hint = `Unable to create database '${match[1]}'. Check for existing database or permissions.`;
      }
      return "Cannot create database. " + hint;
    }

    case "ER_CANT_DROP_DB": {
      const match = fullMessage.match(/Can't drop database '(.+)'/);
      if (match) {
        hint = `Unable to drop database '${match[1]}'. Ensure no active connections or permissions issues.`;
      }
      return "Cannot drop database. " + hint;
    }

    case "ER_DBACCESS_DENIED_ERROR": {
      const match = fullMessage.match(
        /Access denied for user '(.+)' to database '(.+)'/
      );
      if (match) {
        const [, user, db] = match;
        hint = `User '${user}' does not have access to database '${db}'.`;
      }
      return "Database access denied. " + hint;
    }

    case "ER_TABLEACCESS_DENIED_ERROR": {
      const match = fullMessage.match(
        /(SELECT|INSERT|UPDATE|DELETE) command denied to user '(.+)' for table '(.+)'/
      );
      if (match) {
        const [, command, user, table] = match;
        hint = `User '${user}' does not have '${command}' permission on table '${table}'.`;
      }
      return "Table access denied. " + hint;
    }

    case "ER_COLUMNACCESS_DENIED_ERROR": {
      const match = fullMessage.match(
        /(SELECT|INSERT|UPDATE|DELETE) command denied to user '(.+)' for column '(.+)' in table '(.+)'/
      );
      if (match) {
        const [, command, user, column, table] = match;
        hint = `User '${user}' does not have '${command}' permission on column '${column}' in table '${table}'.`;
      }
      return "Column access denied. " + hint;
    }

    case "ER_NO_SUCH_TABLE": {
      const match = fullMessage.match(/Table '(.+)' doesn't exist/);
      if (match) {
        hint = `The table '${match[1]}' does not exist in the database.`;
      }
      return "Table does not exist. " + hint;
    }

    case "ER_NON_UNIQ_ERROR": {
      const match = fullMessage.match(
        /Column '(.+)' in field list is ambiguous/
      );
      if (match) {
        hint = `The column '${match[1]}' is ambiguous. Consider specifying the table name.`;
      }
      return "Ambiguous column. " + hint;
    }

    case "ER_WRONG_FIELD_WITH_GROUP":
      return "Invalid use of field in GROUP BY clause.";

    case "ER_TOO_MANY_ROWS":
      return "Query returned too many rows for a subquery or update.";

    case "ER_CHECK_CONSTRAINT_VIOLATED": {
      const match = fullMessage.match(/Check constraint '(.+)' is violated/);
      if (match) {
        hint = `The check constraint '${match[1]}' was violated.`;
      }
      return "Check constraint violated. " + hint;
    }

    case "ER_PRIMARY_CANT_HAVE_NULL":
      return "Primary key column cannot be null.";

    case "ER_ROW_IS_REFERENCED":
      return "Cannot delete this record. It's still in use.";

    case "ER_CANNOT_ADD_FOREIGN":
      return "Cannot add foreign key constraint. Check referenced table and fields.";

    case "ER_NO_REFERENCED_ROW":
      return "Cannot add or update child row: a foreign key constraint fails.";

    case "ER_ROW_IS_REFERENCED_2":
      return "Cannot delete or update parent row: a foreign key constraint fails.";

    case "ER_CANNOT_CREATE_INDEX":
      return "Cannot create index. Check if the index already exists or if the fields are valid.";

    case "ER_DUP_KEYNAME":
      return "Duplicate key name. An index with this name already exists.";

    case "ER_DUP_ENTRY_AUTOINCREMENT_CASE":
      return "Duplicate entry for auto-increment field. Consider resetting the auto-increment value.";

    case "ER_CANT_CREATE_TABLE":
      return "Cannot create table. Check for existing table or permissions.";

    case "ER_CANT_CREATE_DB":
      return "Cannot create database. Check for existing database or permissions.";

    case "ER_DB_CREATE_EXISTS":
      return "Database already exists.";

    case "ER_DB_DROP_EXISTS":
      return "Database does not exist.";

    case "ER_DB_DROP_DELETE":
      return "Error dropping database. Check for active connections or permissions.";

    case "ER_DB_DROP_RMDIR":
      return "Error removing database directory. Check file system permissions.";

    case "ER_CANT_DELETE_FILE":
      return "Cannot delete file. Check file system permissions.";

    case "ER_CANT_FIND_SYSTEM_REC":
      return "Cannot find system record. The table may be corrupted.";

    case "ER_CANT_GET_STAT":
      return "Cannot get file status. Check file system permissions.";

    case "ER_CANT_LOCK":
      return "Cannot lock file. Check file system permissions.";

    case "ER_CANT_OPEN_FILE":
      return "Cannot open file. Check file system permissions.";

    case "ER_FILE_NOT_FOUND":
      return "File not found. Check file path and permissions.";

    case "ER_FILE_EXISTS_ERROR":
      return "File already exists.";

    case "ER_CANT_READ_DIR":
      return "Cannot read directory. Check file system permissions or existence.";

    case "ER_WRONG_VALUE_FOR_TYPE":
      return "You provided a value that doesn't match the expected data type.";

    case "ER_ILLEGAL_VALUE_FOR_TYPE":
      return "Illegal value provided for a specific column type.";

    case "ER_FIELD_SPECIFIED_TWICE":
      return "A column was specified more than once in the SELECT or INSERT statement.";

    case "ER_WRONG_KEY_COLUMN":
      return "Foreign key references a non-indexed column. Ensure the referenced column has an index.";

    case "ER_TOO_BIG_FIELDLENGTH":
      return "Defined field length is too large. Reduce size of VARCHAR/TEXT/BLOB field.";

    case "ER_TOO_BIG_ROWSIZE":
      return "Row size too large. Normalize the schema or use TEXT/BLOB for large data.";

    case "ER_KEY_COLUMN_DOES_NOT_EXITS":
      return "One or more columns defined in the key do not exist. Check your index/constraint column names.";

    case "ER_TOO_MANY_KEYS":
      return "Table has too many indexes. MySQL allows a limited number — consider dropping unused indexes.";

    case "ER_TOO_MANY_FIELDS":
      return "Too many columns defined in the table. Reduce field count or normalize your schema.";

    case "ER_TOO_LONG_IDENT":
      return "Identifier (column, table, or index name) is too long. MySQL limits names to 64 characters.";

    case "ER_INVALID_DEFAULT":
      return "Invalid default value provided for a column. Check the column's type compatibility.";

    case "ER_AUTO_INCREMENT_COLUMN_REQUIRED":
      return "You're using AUTO_INCREMENT, but haven't defined it on any column. Set it on a suitable primary key column.";

    case "ER_UNIQUE_KEY_NEED_ALL_FIELDS_IN_PF":
      return "Unique key constraint requires all key fields to be part of the primary key. Adjust your schema.";

    case "ER_NO_DEFAULT_FOR_FIELD":
      return "A required column has no default and was not provided. Set a value or alter the column to allow NULL/default.";

    case "ER_OPERAND_COLUMNS":
      return "Incorrect number of columns in a VALUES or SELECT clause. Check if column count matches.";

    case "ER_VIEW_SELECT_CLAUSE":
      return "The SELECT clause in your view has unsupported or incorrect syntax.";

    case "ER_VIEW_SELECT_VARIABLE":
      return "Views cannot reference user-defined variables. Remove variables from the SELECT clause.";

    case "ER_VIEW_SELECT_TMPTABLE":
      return "Views cannot use temporary tables. Rewrite the query to avoid them.";

    case "ER_VIEW_CHECK_FAILED":
      return "A CHECK constraint defined on a view failed. Ensure view constraints are satisfied.";

    case "ER_SP_NO_RECURSIVE_CREATE":
      return "You tried to create a stored procedure that calls itself recursively — that's not allowed.";

    case "ER_SP_ALREADY_EXISTS":
      return "A stored procedure with this name already exists. Use a different name or drop the existing one.";

    case "ER_SP_DOES_NOT_EXIST":
      return "Referenced stored procedure does not exist. Check for typos or missing definitions.";

    case "ER_SP_LILABEL_MISMATCH":
    case "ER_SP_LABEL_REDEFINE":
      return "Label conflict in stored procedure. Ensure each label is unique and defined properly.";

    case "ER_TRIGGER_ALREADY_EXISTS":
      return "Trigger already exists on this table and event. Use a different name or drop the existing trigger.";

    case "ER_TRIGGER_DOES_NOT_EXIST":
      return "Trigger you're trying to alter or drop doesn't exist.";

    case "ER_SIGNAL_EXCEPTION":
    case "ER_SIGNAL_EXCEPTION_HANDLER":
      return "An error was signaled using SIGNAL/RESIGNAL in a stored procedure or trigger. Check condition handling logic.";

    case "ER_TOO_LONG_STRING":
      return "A string value is too long for its target column. Reduce input size or increase column length.";

    case "ER_CONSTRAINT_FAILED":
      return "One of the field values failed a constraint check. Review NOT NULL, UNIQUE, or CHECK constraints.";

    case "ER_INVALID_JSON_TEXT":
      return "Provided JSON text is not valid. Ensure it is well-formed and follows JSON syntax.";

    case "ER_INVALID_JSON_PATH":
      return "The JSON path expression used is invalid. Check for correct syntax and structure.";

    case "ER_INVALID_JSON_DATA":
      return "The value is not valid JSON or does not match the expected structure (e.g., missing keys or wrong types).";

    case "ER_TOO_LONG_TABLE_COMMENT":
      return "The table comment is too long. MySQL limits it to 2048 characters.";

    case "ER_TOO_LONG_FIELD_COMMENT":
      return "The column comment is too long. Keep field comments under 1024 characters.";

    case "ER_TOO_LONG_INDEX_COMMENT":
      return "The index comment is too long. Reduce comment length to fit MySQL's 1024 character limit.";

    default: {
      if (message.includes("Data truncated for column")) {
        const match = message.match(/Data truncated for column '(.+?)'/);
        return match
          ? `Invalid value for field '${match[1]}'.`
          : "Invalid value for one of the fields.";
      }

      if (message.includes("Incorrect string value")) {
        const match = message.match(
          /Incorrect string value: .* for column '(.+?)'/
        );
        return match
          ? `Unsupported characters in field '${match[1]}'.`
          : "One of the fields has unsupported characters (check encoding).";
      }

      if (message.includes("Unknown column")) {
        const match = message.match(/Unknown column '(.+?)'/);
        return match
          ? `Column '${match[1]}' does not exist in the table.`
          : "Your query references a column that doesn't exist.";
      }

      if (message.includes("doesn't have a default value")) {
        const match = message.match(
          /Field '(.+?)' doesn't have a default value/
        );
        return match
          ? `Missing a value for required field '${match[1]}'.`
          : "You're missing a value for a required field.";
      }

      if (message.includes("Incorrect integer value")) {
        const match = message.match(
          /Incorrect integer value: .* for column '(.+?)'/
        );
        return match
          ? `Invalid number for field '${match[1]}'.`
          : "Invalid number provided in a numeric field.";
      }

      if (message.includes("Unknown database")) {
        const match = message.match(/Unknown database '(.+?)'/);
        return match
          ? `The database '${match[1]}' does not exist.`
          : "Specified database does not exist.";
      }

      if (message.includes("Access denied")) {
        const match = message.match(/Access denied for user '(.+?)'/);
        return match
          ? `Access denied for user '${match[1]}'. Check credentials.`
          : "Database access denied. Check your credentials.";
      }

      if (message.includes("Too many connections")) {
        return "Database connection limit exceeded. Try again later.";
      }

      if (message.includes("Deadlock found")) {
        return "Database deadlock occurred. Try rerunning the transaction.";
      }

      if (message.includes("Lock wait timeout exceeded")) {
        return "Query waited too long for a lock. Retry or optimize your query.";
      }

      if (message.includes("Packet for query is too large")) {
        return "Submitted data is too large. Try reducing the size of your input.";
      }

      if (message.includes("Lost connection to MySQL server")) {
        return "Lost connection to the MySQL server during query execution.";
      }

      if (message.includes("Can't connect to MySQL server")) {
        return "Failed to connect to the MySQL server. Check host/port config.";
      }

      if (
        message.includes("Out of memory") ||
        message.includes("Out of resources")
      ) {
        return "The database server ran out of memory or disk resources.";
      }

      if (message.includes("key length")) {
        return "Your index key is too long. Consider reducing column size or index length.";
      }

      if (message.includes("foreign key constraint fails")) {
        const match = message.match(/FOREIGN KEY \(`(.+?)`\) REFERENCES/);
        return match
          ? `Foreign key constraint failed on field '${match[1]}'.`
          : "Foreign key violation. This record depends on another.";
      }

      return fullMessage || code || errno || "Database error occurred.";
    }
  }
}

module.exports = { getFriendlySqlError };
