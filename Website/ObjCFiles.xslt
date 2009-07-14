<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Converts the WSDL file to Objective-C for use in Cocoa applications.
-->
<xsl:stylesheet version="1.0"
	xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
	xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
	xmlns:wsap="http://schemas.xmlsoap.org/ws/2004/08/addressing/policy"
	xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy" 
	xmlns:msc="http://schemas.microsoft.com/ws/2005/12/wsdl/contract"
	xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl"
	xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/"
	xmlns:wsa10="http://www.w3.org/2005/08/addressing"
	xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata"
	xmlns:http="http://schemas.xmlsoap.org/wsdl/http/"
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
	xmlns:s="http://www.w3.org/2001/XMLSchema"
	xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
	xmlns:tns="http://epm.aholdusa.com/webservices/"
	xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/"
	xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
	xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output version="1.0" encoding="iso-8859-1" method="xml" omit-xml-declaration="no" indent="yes"/>
	<xsl:variable name="templateName">ObjCFiles</xsl:variable>
	<xsl:include href="ObjCCommon.xslt"/>

	<xsl:template match="/">
		<package>
			<xsl:attribute name="name"><xsl:value-of select="$serviceName"/>.iPhone</xsl:attribute>
			<folder copy="ObjC/Soap"/>
			<folder copy="ObjC/TouchXML"/>
			<include copy="ObjC/README.rtf"/>
			<xsl:apply-templates/>
		</package>
	</xsl:template>

	<!-- MAIN TEMPLATE FOR ALL DEFINITIONS -->
	<xsl:template match="wsdl:definitions">
		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="$serviceName"/>.h</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="$serviceName"/>.h
	The interface definition of classes and methods for the <xsl:value-of select="$serviceName"/> web service.
	Generated by SudzC.com
*/
			<xsl:call-template name="imports"/>
			<xsl:apply-templates select="wsdl:documentation"/>
/* Add class references */
			<xsl:apply-templates select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name]" mode="import_reference">
				<xsl:sort select="count(descendant::s:element[substring-before(@type, ':') != 's'])"/>
			</xsl:apply-templates>

/* Interface for the service */
			<xsl:call-template name="createInterface"><xsl:with-param name="service" select="wsdl:service"/></xsl:call-template>
		</file>

		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="$serviceName"/>.m</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="$serviceName"/>.m
	The implementation classes and methods for the <xsl:value-of select="$serviceName"/> web service.
	Generated by SudzC.com
*/

#import "<xsl:value-of select="$shortns"/><xsl:value-of select="$serviceName"/>.h"
			<xsl:call-template name="imports"/>
			<xsl:apply-templates select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name]" mode="import">
				<xsl:sort select="count(descendant::s:element[substring-before(@type, ':') != 's'])"/>
			</xsl:apply-templates>

/* Implementation of the service */
			<xsl:call-template name="createImplementation"><xsl:with-param name="service" select="wsdl:service"/></xsl:call-template>
		</file>

		<!-- Interfaces for complex objects -->
		<xsl:apply-templates select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name]" mode="interface">
			<xsl:sort select="position()" order="descending"/>
		</xsl:apply-templates>

		<!-- Implementation for complex objects -->
		<xsl:apply-templates select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name]" mode="implementation">
			<xsl:sort select="position()" order="descending"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xsl:template match="s:complexType" mode="interface_object">
		<xsl:if test="generate-id(.) = generate-id(key('className', @name)[1])">
			<xsl:variable name="baseType">
				<xsl:choose>
					<xsl:when test="descendant::s:extension[@base]">
						<xsl:value-of select="$shortns"/><xsl:value-of select="substring-after(descendant::s:extension/@base, ':')"/>
					</xsl:when>
					<xsl:otherwise>SoapObject</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h
	The interface definition of properties and methods for the <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> object.
	Generated by SudzC.com
*/
<xsl:call-template name="imports"/>

<xsl:apply-templates select="descendant::s:element" mode="import_reference"/>

@interface <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> : <xsl:value-of select="$baseType"/>
{
	<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="interface_variables"/>
}
		<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="interface_properties"/>

	+ (<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;

@end</file>
</xsl:if></xsl:template>

	<xsl:template match="s:complexType" mode="implementation_object"><xsl:if test="generate-id(.) = generate-id(key('className', @name)[1])">
		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.m</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h
	The implementation of properties and methods for the <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> object.
	Generated by SudzC.com
*/
#import "<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h"
<xsl:apply-templates select="descendant::s:element" mode="import"/>

@implementation <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>
		<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="implementation_synthesize"/>

	- (id) init
	{
		if(self = [super init])
		{
<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="implementation_alloc"/>
		}
		return self;
	}

	+ (<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>*)[[<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="implementation"/>
		}
		return self;
	}
	
	- (NSMutableString*) serialize
	{
		NSMutableString* s = [super serialize];
<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="implementation_serialize"/>
		return s;
	}
	
	- (void) dealloc
	{<xsl:apply-templates select="descendant::s:element|descendant::s:attribute" mode="dealloc"/>
		[super dealloc];
	}

@end</file>
</xsl:if></xsl:template>
	
	
	
	<!-- CREATES AN ARRAY -->

	<xsl:template match="s:complexType" mode="interface_array"><xsl:if test="generate-id(.) = generate-id(key('className', @name)[1])">
		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h
	The interface definition of properties and methods for the <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> array.
	Generated by SudzC.com
*/
<xsl:call-template name="imports"/>

<xsl:apply-templates select="descendant::s:element" mode="import_reference"/>

@interface <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> : SoapArray
{
	NSMutableArray *items;
}
	@property (retain, nonatomic) NSMutableArray *items;
	+ (NSMutableArray*) newWithNode: (CXMLNode*) node;
	- (NSMutableArray*) initWithNode: (CXMLNode*) node;
	+ (NSMutableString*) serialize: (NSArray*) array;

@end</file>
</xsl:if></xsl:template>
	
	<xsl:template match="s:complexType" mode="implementation_array">
		<xsl:if test="generate-id(.) = generate-id(key('className', @name)[1])">
			<xsl:variable name="actualType"><xsl:value-of select="substring-after(descendant::s:element/@type, ':')"/></xsl:variable>
			<xsl:variable name="declaredType"><xsl:call-template name="getType"><xsl:with-param name="value" select="descendant::s:element/@type"/></xsl:call-template></xsl:variable>
			<xsl:variable name="arrayType">
				<xsl:choose>
					<xsl:when test="$declaredType = 'BOOL'">NSNumber*;</xsl:when>
					<xsl:when test="$declaredType = 'int'">NSNumber*</xsl:when>
					<xsl:when test="$declaredType = 'long'">NSNumber*</xsl:when>
					<xsl:when test="$declaredType = 'double'">NSNumber*</xsl:when>
					<xsl:when test="$declaredType = 'float'">NSNumber*</xsl:when>
					<xsl:when test="$declaredType = 'short'">NSNumber*</xsl:when>
					<xsl:otherwise><xsl:value-of select="$declaredType"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		<file>
			<xsl:attribute name="filename">Proxy Classes/<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.m</xsl:attribute>/*
	<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h
	The implementation of properties and methods for the <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> array.
	Generated by SudzC.com
*/
#import "<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>.h"
<xsl:apply-templates select="descendant::s:element" mode="import"/>

@implementation <xsl:value-of select="$shortns"/><xsl:value-of select="@name"/>

	@synthesize items;

	+ (NSMutableArray*) newWithNode: (CXMLNode*) node
	{
		return (NSMutableArray*)[[<xsl:value-of select="$shortns"/><xsl:value-of select="@name"/> alloc] initWithNode: node];
	}

	- (NSMutableArray*) initWithNode: (CXMLNode*) node
	{
		[super initWithNode: node];
		items = [[NSMutableArray alloc] init];
		if(node == nil) { return items; }
		for(CXMLElement* child in [node children])
		{
			<xsl:value-of select="$arrayType"/> value = <xsl:choose>
				<xsl:when test="$declaredType = 'NSString*'">[child stringValue];</xsl:when>
				<xsl:when test="$declaredType = 'BOOL'">[NSNumber numberWithBool: [[child stringValue] boolValue]];</xsl:when>
				<xsl:when test="$declaredType = 'int'">[NSNumber numberWithInt: [[child stringValue] intValue]];</xsl:when>
				<xsl:when test="$declaredType = 'short'">[NSNumber numberWithInt: [[child stringValue] shortValue]];</xsl:when>
				<xsl:when test="$declaredType = 'long'">[NSNumber numberWithLong: [[child stringValue] longLongValue]];</xsl:when>
				<xsl:when test="$declaredType = 'double'">[NSNumber numberWithDouble: [[child stringValue] doubleValue]];</xsl:when>
				<xsl:when test="$declaredType = 'float'">[NSNumber numberWithFloat: [[child stringValue] floatValue]];</xsl:when>
				<xsl:when test="$declaredType = 'NSDecimalNumber*'">[NSDecimalNumber decimalNumberWithString: [child stringValue]];</xsl:when>
				<xsl:when test="$declaredType = 'NSDate*'">[Soap dateFromString: [child stringValue]];</xsl:when>
				<xsl:otherwise>[<xsl:value-of select="substring-before($declaredType, '*')"/> newWithNode: child];</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="contains($declaredType, '*') and not(starts-with($declaredType, 'NS'))">
			if(value != nil) {
				[items addObject: value];
			}
			[value release];</xsl:when>
				<xsl:otherwise>
			[items addObject: value];</xsl:otherwise></xsl:choose>		
		}
		return items;
	}
	
	+ (NSMutableString*) serialize: (NSArray*) array
	{
		NSMutableString* s = [NSMutableString string];
		for(id item in array) {
			[s appendFormat: @"&lt;<xsl:value-of select="$actualType"/>&gt;%@&lt;/<xsl:value-of select="$actualType"/>&gt;", <xsl:call-template name="serialize">
				<xsl:with-param name="name">item</xsl:with-param>
				<xsl:with-param name="type"><xsl:value-of select="$arrayType"/></xsl:with-param>
				<xsl:with-param name="xsdType"><xsl:value-of select="$actualType"/></xsl:with-param>
			</xsl:call-template>];
		}
		return s;
	}

	- (void) dealloc
	{
		[super dealloc];
	}
@end</file>
</xsl:if></xsl:template>

</xsl:stylesheet>
