<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DEN_PatientNotification</fullName>
        <description>DEN_PatientNotification</description>
        <protected>false</protected>
        <recipients>
            <field>Patient__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/DEN_ClientNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>DEN_StatusApprove</fullName>
        <field>Status__c</field>
        <literalValue>Zaakceptowana</literalValue>
        <name>DEN_StatusApprove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DEN_StatusReject</fullName>
        <field>Status__c</field>
        <literalValue>Odrzucona</literalValue>
        <name>DEN_StatusReject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
