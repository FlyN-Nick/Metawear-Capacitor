# metawear-capacitor

Capacitor plugin for metawear's swift sdk.

## Install

```bash
npm install metawear-capacitor
npx cap sync
```

## API

<docgen-index>

* [`connect()`](#connect)
* [`disconnect()`](#disconnect)
* [`startData()`](#startdata)
* [`startAccelData()`](#startacceldata)
* [`startGyroData()`](#startgyrodata)
* [`stopData()`](#stopdata)
* [`downloadData(...)`](#downloaddata)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### connect()

```typescript
connect() => Promise<null>
```

Connects to the metawear sensor.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### disconnect()

```typescript
disconnect() => Promise<null>
```

Disconnect metawear sensor.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startData()

```typescript
startData() => Promise<null>
```

Start accel and gryo data streaming and on-board logging.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startAccelData()

```typescript
startAccelData() => Promise<null>
```

Start accel data streaming and on-board logging. 

Listen in JS for the logging ID with:
MetawearCapacitor.addListener('accelLogID', (logID) -&gt; { ... });

Listen in JS with:
MetawearCapacitor.addListener('accelData', (accel) =&gt; { ... });

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startGyroData()

```typescript
startGyroData() => Promise<null>
```

Start gyro data streaming and on-board logging.

Listen in JS for the logging ID with:
MetawearCapacitor.addListener('gyroLogID', (logID) -&gt; { ... });

Listen in JS for data stream with:
MetawearCapacitor.addListener('gyroData', (gyro) =&gt; { ... });

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### stopData()

```typescript
stopData() => Promise<null>
```

Stop data streaming and on-board logging.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### downloadData(...)

```typescript
downloadData(ID: String) => Promise<null>
```

Downloads the log data from the metawear sensor, given log ID.

Listen in JS for the log data with:
MetawearCapacitor.addListener('logData-ID', (logData) -&gt; { ... });

Listen in JS for log finish with:
MetawearCapacitor.addListener('logFinish-ID', () =&gt; { ... });

| Param    | Type                                      |
| -------- | ----------------------------------------- |
| **`ID`** | <code><a href="#string">String</a></code> |

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### Interfaces


#### String

Allows manipulation and formatting of text strings and determination and location of substrings within strings.

| Prop         | Type                | Description                                                  |
| ------------ | ------------------- | ------------------------------------------------------------ |
| **`length`** | <code>number</code> | Returns the length of a <a href="#string">String</a> object. |

| Method                | Signature                                                                                                                      | Description                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**          | () =&gt; string                                                                                                                | Returns a string representation of a string.                                                                                                  |
| **charAt**            | (pos: number) =&gt; string                                                                                                     | Returns the character at the specified index.                                                                                                 |
| **charCodeAt**        | (index: number) =&gt; number                                                                                                   | Returns the Unicode value of the character at the specified location.                                                                         |
| **concat**            | (...strings: string[]) =&gt; string                                                                                            | Returns a string that contains the concatenation of two or more strings.                                                                      |
| **indexOf**           | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the position of the first occurrence of a substring.                                                                                  |
| **lastIndexOf**       | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the last occurrence of a substring in the string.                                                                                     |
| **localeCompare**     | (that: string) =&gt; number                                                                                                    | Determines whether two strings are equivalent in the current locale.                                                                          |
| **match**             | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; <a href="#regexpmatcharray">RegExpMatchArray</a> \| null                | Matches a string with a regular expression, and returns an array containing the results of that search.                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replaceValue: string) =&gt; string                                       | Replaces text in a string, using a regular expression or search string.                                                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replacer: (substring: string, ...args: any[]) =&gt; string) =&gt; string | Replaces text in a string, using a regular expression or search string.                                                                       |
| **search**            | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; number                                                                  | Finds the first substring match in a regular expression search.                                                                               |
| **slice**             | (start?: number \| undefined, end?: number \| undefined) =&gt; string                                                          | Returns a section of a string.                                                                                                                |
| **split**             | (separator: string \| <a href="#regexp">RegExp</a>, limit?: number \| undefined) =&gt; string[]                                | Split a string into substrings using the specified separator and return them as an array.                                                     |
| **substring**         | (start: number, end?: number \| undefined) =&gt; string                                                                        | Returns the substring at the specified location within a <a href="#string">String</a> object.                                                 |
| **toLowerCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to lowercase.                                                                              |
| **toLocaleLowerCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Converts all alphabetic characters to lowercase, taking into account the host environment's current locale.                                   |
| **toUpperCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to uppercase.                                                                              |
| **toLocaleUpperCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Returns a string where all alphabetic characters have been converted to uppercase, taking into account the host environment's current locale. |
| **trim**              | () =&gt; string                                                                                                                | Removes the leading and trailing white space and line terminator characters from a string.                                                    |
| **substr**            | (from: number, length?: number \| undefined) =&gt; string                                                                      | Gets a substring beginning at the specified location and having the specified length.                                                         |
| **valueOf**           | () =&gt; string                                                                                                                | Returns the primitive value of the specified object.                                                                                          |


#### RegExpMatchArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |


#### RegExp

| Prop             | Type                 | Description                                                                                                                                                          |
| ---------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`source`**     | <code>string</code>  | Returns a copy of the text of the regular expression pattern. Read-only. The regExp argument is a Regular expression object. It can be a variable name or a literal. |
| **`global`**     | <code>boolean</code> | Returns a Boolean value indicating the state of the global flag (g) used with a regular expression. Default is false. Read-only.                                     |
| **`ignoreCase`** | <code>boolean</code> | Returns a Boolean value indicating the state of the ignoreCase flag (i) used with a regular expression. Default is false. Read-only.                                 |
| **`multiline`**  | <code>boolean</code> | Returns a Boolean value indicating the state of the multiline flag (m) used with a regular expression. Default is false. Read-only.                                  |
| **`lastIndex`**  | <code>number</code>  |                                                                                                                                                                      |

| Method      | Signature                                                                     | Description                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **exec**    | (string: string) =&gt; <a href="#regexpexecarray">RegExpExecArray</a> \| null | Executes a search on a string using a regular expression pattern, and returns an array containing the results of that search. |
| **test**    | (string: string) =&gt; boolean                                                | Returns a Boolean value that indicates whether or not a pattern exists in a searched string.                                  |
| **compile** | () =&gt; this                                                                 |                                                                                                                               |


#### RegExpExecArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |

</docgen-api>
