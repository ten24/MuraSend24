<cfcomponent extends="mura.plugin.pluginGenericEventHandler">

	<cffunction name="onApplicationLoad">
		<cfargument name="event">
		<cfset request.pluginConfig=variables.pluginConfig>
		<cfset variables.pluginConfig.addEventHandler(this)>
	</cffunction>

	<cffunction name="onBeforeFormSubmitSave" access="public" returntype="void" output="true">
		<cfargument name="$">
		
		<cfif structKeyExists(request,"send24Integration") AND structKeyExists(request,"email") AND isValid("email",request.email)>
			<cfset var bean = $.event("formBean") />
			<cfset var rsForm=bean.getAllValues()>
			<cfparam name="request.mailingListIDs" default="0">
			
			<cfset var subscribeURL = "#pluginConfig.getSetting('send24Domain')#/index.cfm/event/api/method/subscribe/apikey/#pluginConfig.getSetting('apikey')#/emailAddress/#request.email#/mailingListIDs/#request.mailingListIDs#" />
			<cfloop list="#request.fieldnames#" index="local.fn">
				<cfif listFindNoCase("email,mailingListIDs",fn) EQ 0>
					<cfset subscribeURL &= "/#fn#/#request[fn]#" />
				</cfif>
			</cfloop>
			<cfhttp url="#subscribeURL#" />
			<cfif cfhttp.ResponseHeader.status_code NEQ "200">
				<cfset response = deserializeJSON(cfhttp.FileContent) />
				<cfset $.event("apiError",response.data) />
			</cfif>
			<!---<cfdump label="Result" var="#cfhttp#" />
			<cfdump label="Susbcribe URL" var="#subscribeURL#" abort="true"  />--->
		</cfif>
			
	</cffunction>

	<cffunction name="onAfterFormSubmitSave" access="public" returntype="void" output="false">
		<cfargument name="$">

	</cffunction>

	<cffunction name="onFormSubmitResponseRender" access="public" output="false">
		<cfargument name="$">
		
		<cfreturn $.event("apiError") />
	</cffunction>

</cfcomponent>