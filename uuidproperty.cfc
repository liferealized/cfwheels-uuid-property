<cfcomponent mixin="model" output="false">

  <cffunction name="init">
    <cfset this.version = "1.1.8">
    <cfreturn this>
  </cffunction>

  <cffunction name="uuidProperty" access="public" output="false" returntype="void">
    <cfargument name="properties" type="string" required="false" default="" />
    <cfscript>
      var loc = {};
      
      if (StructKeyExists(arguments, "property"))
        arguments.properties = arguments.property;
      
      if (!StructKeyExists(variables.wheels.class, "uuidProperties"))
        variables.wheels.class.uuidProperties = [];

      for (loc.property in listToArray(arguments.properties))
        ArrayAppend(variables.wheels.class.uuidProperties, loc.property);

      // remove any duplicates
      variables.wheels.class.uuidProperties = ListToArray(ListRemoveDuplicates(ArrayToList(variables.wheels.class.uuidProperties)));
      
      afterFind(method="$binaryPropertiesToUUID");
      afterInitialization(method="$binaryPropertiesToUUID");
      afterSave(method="$binaryPropertiesToUUID");
      beforeValidation(method="$UUIDPropertiesToBinary");
      beforeDelete(method="$UUIDPropertiesToBinary");
    </cfscript>
  </cffunction>

  <cffunction name="isUuid" access="public" output="false" returntype="boolean">
    <cfargument name="string" type="string" required="true" />
    <!--- example UUID (includes CF uuids): f136bf63-8fd4-4683-bdf1-e865d12e53c2 --->
    <cfreturn REFindNoCase("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", arguments.string) />
  </cffunction>

  <cffunction name="byteArrayToUUID" access="public" output="false" returntype="string">
    <cfargument name="byteArray" type="binary" required="true" />
    <cfscript>
      var loc = {};

      loc.byteBuffer = createObject("java", "java.nio.ByteBuffer").wrap(arguments.byteArray);
      loc.longBuffer = loc.byteBuffer.asLongBuffer();

      loc.uuid = createObject("java", "java.util.UUID").init(loc.longBuffer.get(0), loc.longBuffer.get(1));
    </cfscript>
    <cfreturn loc.uuid.toString() />
  </cffunction>

  <cffunction name="UUIDToByteArray" access="public" output="false" returntype="string">
    <cfargument name="string" type="string" required="true" />
    <cfscript>
      var loc = {};

      loc.uuid = createObject("java", "java.util.UUID").fromString(arguments.string);

      // get our Bytes
      loc.msb = loc.uuid.getMostSignificantBits();
      loc.lsb = loc.uuid.getLeastSignificantBits();

      loc.emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray();
      loc.byteClass = loc.emptyByteArray.getClass().getComponentType();
      loc.byteArray = createObject("java", "java.lang.reflect.Array").newInstance(loc.byteClass, 16);

      loc.byteBuffer = createObject("java", "java.nio.ByteBuffer").wrap(loc.byteArray);
      loc.longBuffer = loc.byteBuffer.asLongBuffer();

      loc.longBuffer.put(0, loc.msb);
      loc.longBuffer.put(1, loc.lsb);
    </cfscript>
    <cfreturn loc.byteArray />
  </cffunction>

  <cffunction name="$UUIDPropertiesToBinary" access="public" output="false" returntype="void">
    <cfargument name="properties" type="array" required="false" default="#variables.wheels.class.uuidProperties#" />
    <cfscript>
      var loc = {};

      for (loc.item in arguments.properties)
        if (StructKeyExists(this, loc.item) and IsUuid(this[loc.item]))
          this[loc.item] = UUIDToByteArray(this[loc.item]);
    </cfscript>
  </cffunction>

  <cffunction name="$binaryPropertiesToUUID" access="public" output="false" returntype="void">
    <cfargument name="properties" type="array" required="false" default="#variables.wheels.class.uuidProperties#" />
    <cfscript>
      var loc = {};

      for (loc.item in arguments.properties)
        if (StructKeyExists(this, loc.item) and IsBinary(this[loc.item]))
          this[loc.item] = byteArrayToUUID(this[loc.item]);
    </cfscript>
  </cffunction>
  
</cfcomponent>