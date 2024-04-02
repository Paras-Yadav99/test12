@isTest
public class Email2LeadTest {
	@isTest
    public static void testMethod1(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Undele';
        email.fromname = 'Test Test';
        email.fromAddress = 'Test@email.com';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Test zid-';
        email.toAddresses = new List<String>{'craigslist@zadoon.com'};
        
     	Contact con = new Contact(
			lastName = 'test',
            Email = 'Test@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California'
        );
        insert con;
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
    }

    
    @isTest
    public static void testMethod2(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '------ Post your reply above this line ------\n\nHi,\n\nCathie Taormina from Cassville, New Jersey, USA is interested in your item on Machinio: 2003 Mack CV713 in Crofton, MD (#61479430). Stock / ID: ZID-132652\n\nFor an immediate response, please call the buyer (+1 631-681-6700) or click here to contact this buyer using Machinio.\n\nYou can reply directly to this message to contact the buyer.\n\nName: Cacdfdf Tarr\nEmail: harleyshelton12@aol.com\nPhone: 630-681-6710\nCompany: Taormina and son\'s equipment\nLocation: Cassville, New Jersey, USA\nZip Code: 11201\nPrice: $36,900\nComments: I would like to see more images of this listing.\n\n\n\n';

        email.subject = 'Machinio Weekly Lead Follow-up dfjed af';
        email.fromname = 'Test Test2';
        env.fromAddress = 'machinio@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'machinio@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Zadoon Machinio Leads', lead.LeadSource);
        
    }

    @isTest
    public static void testMethod3(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String machineTrader = 'This SALES LEAD was left for you moments ago on Machinerytrader.com.\nThis SALES LEAD has been placed on Sandhills Cloud:\nView Lead on Sandhills Cloud\n** IMPORTANT NOTE: DO NOT click on \'Reply\' to respond to this message!! If you click \'Reply\' to this email your response WILL NOT BE SEEN by the equipment buyer.\nInstead, use the contact information provided below by the person submitting the email.\nIf you have questions about this instant email service, please call (800) 247-4898.\nFrom: Ran Olkkk\nLocation: 17821\nPhone: +1 570-214-0093\nFax:\nEmail: Polshef1@ptd.ner\nRegarding: New Offer For 1977 DEERE 350CE ZID-128370\nListing: https://www.machinerytrader.com/listings/construction-equipment/for-sale/33919169/\nUnit Location: Patterson, New York\nDealer Phone: +14439046000\nStock Number: ZID-128370\nPrice: 10925\nMessage:\nOffer: $8,000.00\nClick Here To Finance Your Customer\nClick Here For Shipping Information\nClick Here For Insurance Information\nIf you are not a member of the Dealer Service’s program but would like more information about it, please contact your advertising representative or call (800) 247-4898\n';

        email.subject = 'Test';
        email.fromname = 'Test Test3';
        env.fromAddress = 'mt@zadoon.com';
        email.plainTextBody = machineTrader;
        email.toAddresses = new List<String>{'mt@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        //System.assertEquals('mt@zadoon.com', lead.LeadSource);
    }

    @isTest
    public static void testMethod4(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String strMLS = 'since 1958\n\n=== Sales Lead ===\n\n\nJack whatley sent the following email in reference to your listing on\nwww.MyLittleSalesman.com: \n\nLeeBoy 1000D Asphalt Paver\n<https://www.mylittlesalesman.com/2004-leeboy-1000d-asphalt-paver-9775161>\n*MLS #:* 9775161\n*Stock #:* ZID-128077\n\nThe following is the contact details for Jack whatley: \n\n*Name:* Jackfds whatleydfd\n*Email:* whatley081@sbcglobal.net\n*Phone:* 287-250-0300\n*Source:* www.MyLittleSalesman.com\n\n*Message:*\nIs the machine still available And Did you just recently get it painted?  \n\nManage Your Leads\n<https://www.mylittlesalesman.com/admin/listings/leads>    \n';

        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'mylittlesalesman@zadoon.com';
        email.plainTextBody = strMLS;
        email.toAddresses = new List<String>{'mylittlesalesman@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('My Little Salesman', lead.LeadSource);
    }

    @isTest
    public static void testMethod5(){
        String mobile;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        mobile = emailProcess.getMLSDataFromMail2('DO NOT REPLY to this text message. Text message them back at +19784233253"', 'Text message them back at');
        Test.stopTest();
        
        System.assertEquals('+19784233253', mobile);
        
    }
/*
    @isTest
    public static void testMethod7(){
        String mobile;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        mobile = emailProcess.getMLSDataFromMail2('DO NOT REPLY to this text message. Text message them back at +19784233253"', 'Text message them back at');
        Test.stopTest();
        
        System.assertEquals('+19784233253', mobile);
        
    }
*/
    @isTest
    public static void testMethod6(){
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        email = emailProcess.getEmailFromETHTMLData('<a href="mailto:billwalcutt@yahoo.com" target="_blank">billwalcutt@yahoo.com</a>', 'Email: </strong><a href="mailto:billwalcutt@yahoo.com" target="_blank">');
        phone = emailProcess.getETDataFromHTMLMail('Phone: </strong>6074123123</p>','Phone: </strong>');

        Test.stopTest();
    
        
    }
    
    @isTest
    public static void testMethod9(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateRitchieData('<p style="line-height:16pt;text-align:justify;margin-bottom:5px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt"><span style="color:#888;font-size:10pt">Buyer\'s contact details:</span><br> Jay<br> <a href="mailto:jayjyjns@gmail.com" target="_blank">jayjyjns@gmail.com</a><br> (406) 222-2538<br> <br> <span style="color:#888;font-size:10pt">Message from buyer:</span></font> </p>', ld);

        Test.stopTest();
    
        
    }

    @isTest
    public static void testMethod8(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateEquipmentTraderData('', ld);
        Test.stopTest();
    }

    @isTest
    public static void testMethod10(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateRitchieData('<tbody><tr> <td style="font-size:0px;padding:0px 30px"> <table cellpadding="0" cellspacing="0" border="0" align="center"> <tbody><tr> <td width="550" colspan="2" style="font-size:0px"> <a href="https://groove.grvlnk4.com/url/g25cmes716qy0aqslj64l/aHR0cDovL3B1Yi5yaXRjaGllbGlzdC5jb20vcHVibGljL3IvNCtCUVpZSk1kYjZjQkFyVlpBd0x5Zy9zalpWZzVSbVQzdjEwUFRxZmN6VCtBL0xBem1ITm1aUWlTaGR0NnZmVHNvX0EjZ3Jvb3Zlc3VtOi0xMDM1OTUzNTg5" style="font-size:0;text-decoration:none;margin:0" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://groove.grvlnk4.com/url/g25cmes716qy0aqslj64l/aHR0cDovL3B1Yi5yaXRjaGllbGlzdC5jb20vcHVibGljL3IvNCtCUVpZSk1kYjZjQkFyVlpBd0x5Zy9zalpWZzVSbVQzdjEwUFRxZmN6VCtBL0xBem1ITm1aUWlTaGR0NnZmVHNvX0EjZ3Jvb3Zlc3VtOi0xMDM1OTUzNTg5&amp;source=gmail&amp;ust=1657656692684000&amp;usg=AOvVaw2E9qRTB-r2S9TBEAUUulS3"><img src="https://ci5.googleusercontent.com/proxy/vWqiLVEoM12Y_1RRqkIEwpFgBE9xy0GPvHcRJUUMuFHmJ-TSbWKVoCS0_xUwd0S5O3p59totTHTPWO3vrUL9y49xqGPfXJCcTnYYzorJOMB2ox8hpSybOonTxcRRqc2A8q2lK_7_HaVOVRbUyLHTiILRHPO7D5VuMAA4=s0-d-e1-ft#http://pub.ritchielist.com/public/r/3l+pKpOudUTxEVE2EVhtJQ/sjZVg5RmT3v10PTqfczT+A/LAzmHNmZQiShdt6vfTso_A?safe-img-pb" width="100%" class="CToWUd"></a> </td> </tr> <tr> <td width="350" style="font-size:0px;padding-top:10px" align="center" valign="top"> <p style="line-height:16pt;text-align:left"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt;font-weight:bold"><a href="https://groove.grvlnk4.com/url/g25cmes716qy0aqslj64l/aHR0cDovL3B1Yi5yaXRjaGllbGlzdC5jb20vcHVibGljL3IvNCtCUVpZSk1kYjZjQkFyVlpBd0x5Zy9zalpWZzVSbVQzdjEwUFRxZmN6VCtBL0xBem1ITm1aUWlTaGR0NnZmVHNvX0EjZ3Jvb3Zlc3VtOi0xMDM1OTUzNTg5" style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt;color:#000000;text-decoration:none" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://groove.grvlnk4.com/url/g25cmes716qy0aqslj64l/aHR0cDovL3B1Yi5yaXRjaGllbGlzdC5jb20vcHVibGljL3IvNCtCUVpZSk1kYjZjQkFyVlpBd0x5Zy9zalpWZzVSbVQzdjEwUFRxZmN6VCtBL0xBem1ITm1aUWlTaGR0NnZmVHNvX0EjZ3Jvb3Zlc3VtOi0xMDM1OTUzNTg5&amp;source=gmail&amp;ust=1657656692684000&amp;usg=AOvVaw2E9qRTB-r2S9TBEAUUulS3">Komatsu PC220LC-8, 2008</a></font> </p> </td> <td width="150" style="font-size:0px" align="center" valign="top"> <p style="line-height:16pt;text-align:right;padding-top:10px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt;font-weight:bold">USD 75,000</font> </p> </td> </tr> </tbody></table> </td> </tr> <tr> <td style="font-size:0px;padding:20px 30px 0px 30px"> <p style="line-height:16pt;text-align:justify;margin-bottom:5px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt"><span style="color:#888;font-size:10pt">Message from buyer:</span></font> </p> </td> </tr> <tr> <td style="font-size:0px;padding:0px 30px"> <table width="100%" cellpadding="0" cellspacing="0" border="0"> <tbody><tr> <td style="font-size:0px;padding:20px 20px;background-color:#f0f0f0"> <p style="line-height:16pt;text-align:justify"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt;font-style:italic">Call me anytime today</font> </p> </td> </tr> </tbody></table> </td> </tr> <tr> <td style="font-size:0px;padding:20px 30px 20px 30px"> <p style="line-height:16pt;text-align:justify;margin-bottom:5px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt">Oscar Diaz / <a href="mailto:osc.diaz077@yahoo.com" target="_blank">osc.diaz077@yahoo.com</a> / <a href="tel:8323703992" target="_blank">8323703992</a> / United States<br> </font> </p> <p style="line-height:16pt;text-align:justify;margin-top:20px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt">If you want to respond to this buyer, just click the button below:</font><br><br> </p> </td> </tr> </tbody>', ld);

        Test.stopTest();
    }

    @isTest
    public static void testMethod11(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateRitchieData('<p style="line-height:16pt;text-align:justify;margin-bottom:5px"> <font style="font-family:Arial,sans-serif,\'Roboto\';font-size:12pt"><span style="color:#888;font-size:10pt">Buyer\'s contact details:</span><br> Jay<br> <a href="mailto:jayjyjns@gmail.com" target="_blank">jayjyjns@gmail.com</a><br> (406) 222-2538<br> <br> <span style="color:#888;font-size:10pt">Message from buyer:</span></font> </p>', ld);

        Test.stopTest();
    }

    @isTest
    public static void testMethod12(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateRitchieData('<tbody><tr> <td colspan="2" align="left" style="padding:25px 25px 25px 25px;font-family:Arial,Helvetica,sans-serif;font-size:10px;color:#000000"><span style="font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#000000">مرحبا، أود الحصول على مزيد من المعلومات عن Caterpillar D8T. هل يمكن أن تتصل بي؟<br> شكرا.</span></td> </tr> <tr> <td align="left" style="padding:10px 25px 10px 25px;border-top:1px solid #d4d4d4;background-color:#efefef"><font face="Arial, sans-serif" style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#8e8e8e">Sender <span style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#000000">Sherif altayyar</span></font></td> <td align="left" style="padding:10px 25px 10px 25px;border-top:1px solid #d4d4d4;background-color:#efefef"><font face="Arial, sans-serif" style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#8e8e8e">E-mail address: <a href="mailto:profile20fx@yahoo.com" style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#2296ba" target="_blank">profile20fx@yahoo.com</a> </font></td> </tr> <tr> <td align="left" style="padding:10px 25px 10px 25px;border-top:1px solid #d4d4d4;background-color:#efefef"><font face="Arial, sans-serif" style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#8e8e8e"> Phone number: <span style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#000000">+20 +201110230044</span></font></td> <td align="left" style="padding:10px 25px 10px 25px;border-top:1px solid #d4d4d4;background-color:#efefef"><font face="Arial, sans-serif" style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#8e8e8e"> Location <span style="font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:left;color:#000000">Egypt</span></font></td> </tr> </tbody>', ld);
        Test.stopTest();
    }
     @isTest
    public static void testMethod13(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateRitchieHTMLData('<p style="font-size: 16px; margin-left: 25px; color: #637381; font-weight: 400;"><strong>Buyer Contact Info</strong><br> hi good night, i will like to know the price for the machine.<br> <br> Yudhisthir Seecharan<br> yudhisthirseecharan@gmail.com<br> (Windows 10 Outlook and Yahoo users click the email address above to reply)<br> 592-6198844<br> <br> <strong>Listing Details</strong> - <a name="www_rockanddirt_com_listings___Year" href="http://links.mkt3797.com/ctt?ms=MjYyODQ2NjYS1&amp;kn=1&amp;r=LTU3NTg3MjE2NTUS1&amp;b=0&amp;j=MjI0NjcwMTkxNgS2&amp;mt=1&amp;rt=0">View Listing</a><br> <a name="www_rockanddirt_com_listings___Year___" href="http://links.mkt3797.com/ctt?ms=MjYyODQ2NjYS1&amp;kn=3&amp;r=LTU3NTg3MjE2NTUS1&amp;b=0&amp;j=MjI0NjcwMTkxNgS2&amp;mt=1&amp;rt=0"><img align="left" width="150px" style="" src="https://cdn1.boatline.com/v1/media/62ec9f0039d0d54459725ffd.jpg" height="100px" border="0"></img></a> 1984 Caterpillar 936 - ZID-135351 -  </p><p>1984 Caterpillar, 936, Wheel Loaders, -Pin on bucket - GP<r', ld);
        Test.stopTest();
    }
     @isTest
    public static void testMethod14(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'test';
        String email;
        String phone;
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        ld = emailProcess.populateMachineTraderHTMLData('<p style="margin: 0; font-size: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 14px;"><strong>Phone:</strong> <a href="" target="_blank">+12523332142</a></span></p>                                                                                                                                                                <p style="margin: 0; font-size: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 14px;"><strong>Email:</strong> <a href="mailto:ernestcerveny@yahoo.com?subject=Message+<span style="font-size: 14px;"><strong>Stock Number:</strong> ZID-133866</span></p>', ld);
        Test.stopTest();
    }
    @isTest
    public static void testMethod15(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'AT&T Customer Service Reply To Your Reply';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Test zid-1234';
        email.toAddresses = new List<String>{'jagdishparihar508@gmail.com'};
        
     	Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test1@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California'
        );
        insert con;
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
    }
    
    @isTest
    public static void testMethod16(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '------ Post your reply above this line ------\n\nHi,\n\nCathie Taormina from Cassville, New Jersey, USA is interested in your item on Machinio: 2003 Mack CV713 in Crofton, MD (#61479430). Stock / ID: ZID-132652\n\nFor an immediate response, please call the buyer (+1 631-681-6700) or click here to contact this buyer using Machinio.\n\nYou can reply directly to this message to contact the buyer.\n\nName: Cacdfdf Tarr\nEmail*harleyshelton12@aol.com\nPhone: 630-681-6710\nCompany: Taormina and son\'s equipment\nLocation: Cassville, New Jersey, USA\nZip Code: 11201\nPrice: $36,900\nComments: I would like to see more images of this listing.\n\n\n\n';

        email.subject = 'Automatic reply Test';
        email.fromname = 'Test Test2';
        env.fromAddress = '	equipmenttrader@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'equipmenttrader@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Equipment Trader', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod17(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '------ Post your reply above this line ------\n\nHi,\n\nCathie Taormina from Cassville, New Jersey, USA is interested in your item on Machinio: 2003 Mack CV713 in Crofton, MD (#61479430). Stock / ID: ZID-132652\n\nFor an immediate response, please call the buyer (+1 631-681-6700) or click here to contact this buyer using Machinio.\n\nYou can reply directly to this message to contact the buyer.\n\nName: Cacdfdf Tarr\nEmail: harleyshelton12@aol.com\nPhone: 630-681-6710\nCompany: Taormina and son\'s equipment\nLocation: Cassville, New Jersey, USA\nZip Code: 11201\nPrice: $36,900\nComments: I would like to see more images of this listing.\n\n\n\n';

        email.subject = 'PRICE DROP	 Test';
        email.fromname = 'Test Test2';
        env.fromAddress = 'mascus@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'mascus@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Mascus', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod18(){
        Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California',
            MobilePhone = '+19703100202'
        );
        insert con;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = 'You have received a voicemail from Hardy Personal Hardy Bora +19703100202.\n\nMessage Link:\nhttps://zadoon1.mytalkdesk.com/interactions/138557ab4ec34f359e0f6d17205fd15b/recordings/0.mp3\n.\n\n\nThank you\nTalkdesk\n© 2023 Talkdesk, Inc, All Rights Reserved';

        email.subject = 'Test';
        email.fromname = 'Auto-reply from d.r.l@skynet.be';
        env.fromAddress = 'callback@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'callback@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Call Back', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod19(){
        Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California',
            MobilePhone = '+19703100202'
        );
        insert con;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = 'You have received a voicemail from Hardy Personal Hardy Bora +19703100202.\n\nMessage Link:\nhttps://zadoon1.mytalkdesk.com/interactions/138557ab4ec34f359e0f6d17205fd15b/recordings/0.mp3\n.\n\n\nThank you\nTalkdesk\n© 2023 Talkdesk, Inc, All Rights Reserved';

        email.subject = 'Test';
        email.fromname = 'efhdnxrhjeujdx';
        email.fromAddress = 'sales@nleq.com';
        env.fromAddress = 'sales@nleq.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'sales@nleq.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        //System.assertEquals(email.subject, lead.Subject__c);
        //System.assertEquals('Call Back', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod20(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '<https://groove.grvlnk4.com/url/j4qtal9pkton4td63l89jh/aHR0cHM6Ly9tYWlsLmdvb2dsZS5jb20vbWFpbC91LzAvI21fLTI4NzMxOTg4MTk4NjM5NDc4N18jZ3Jvb3Zlc3VtOjc5MTgwMjAxNg%3D%3D> Wanted To Buy! Hello Zadoon One of our potential buyers has created the following Want To Buy ad. Maybe you have the item they\'re looking for? Buyer\'s contact details: Harper Higgins harperhiggins123@gmail.com 9107536390 Wanted To Buy: Make - Model Na Na Construction Off-Highway Haul Trucks Year (Min-Max) 2000-2010 Price (Min-Max) 0-20000 Message: You can view all Want To Buy ads by logging in to your account Sincerely, Your Ritchie List Team contact@ritchielist.com';

        email.subject = 'PRICE DROP	 Test';
        email.fromname = 'Test Test2';
        env.fromAddress = '';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'ritchielist@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Iron Site - Ritchie List', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod21(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '<https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly9tYWlsLmdvb2dsZS5jb20vbWFpbC91LzAvI21fMTMxMzU0MDc1NjU4NDY4MTI5MV8jZ3Jvb3Zlc3VtOjEwNDcxMDEzNDg%3D> A buyer is interested in your listing Hello Zadoon, A potential buyer has sent you an inquiry regarding an item you have listed for sale. New buyer inquiry for your Caterpillar 770 AC39213F <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> Caterpillar 770, <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> USD Buyer\'s contact details: Fahad aljohani Aljuhani.s.s.co@hotmail.com 0553343168 Message from buyer: Hello give me last price to port The potential buyer has requested to secure the transaction through Ritchie Bros *PurchaseSafe™* service. This service provides verification, ensures a secure payment, and transfers the title. If you decide to sell your equipment to this buyer, you will need to select the *PurchaseSafe™* workflow and fill out the required information in our inventory management system. Learn more <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL3NvbHV0aW9uc2ZvcmRlYWxlcnMuYXNweD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjkwNjY5Njk5Ng%3D%3D> Please respond to the potential buyer at your earliest convenience. Helpful tip: you can update your listing with new information any time. You can view all your leads by logging in to your account. Sincerely, Your Ritchie List Team contact@ritchielist.com';

        email.subject = 'PRICE DROP	 Test';
        email.fromname = 'Test Test2';
        env.fromAddress = 'ritchielist@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'ritchielist@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Iron Site - Ritchie List', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod22(){
        Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test72@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California',
            MobilePhone = '+19703100202'
        );
        insert con;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = 'You have received a voicemail from Hardy Personal Hardy Bora +19703100202.\n\nMessage Link:\nhttps://zadoon1.mytalkdesk.com/interactions/138557ab4ec34f359e0f6d17205fd15b/recordings/0.mp3\n.\n\n\nThank you\nTalkdesk\n© 2023 Talkdesk, Inc, All Rights Reserved';

        email.subject = 'Test';
        email.fromname = 'Paras1 Test';
        email.fromAddress = 'Test72@email.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'finance@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Finance', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod23(){
        Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test72@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California',
            MobilePhone = '+19703100202'
        );
        insert con;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = 'You have received a voicemail from Hardy Personal Hardy Bora +19703100202.\n\nMessage Link:\nhttps://zadoon1.mytalkdesk.com/interactions/138557ab4ec34f359e0f6d17205fd15b/recordings/0.mp3\n.\n\n\nThank you\nTalkdesk\n© 2023 Talkdesk, Inc, All Rights Reserved';

        email.subject = 'Test';
        email.fromname = 'Paras1 Test';
        email.fromAddress = 'Test72@email.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'admin@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Admin', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod24(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '<https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly9tYWlsLmdvb2dsZS5jb20vbWFpbC91LzAvI21fMTMxMzU0MDc1NjU4NDY4MTI5MV8jZ3Jvb3Zlc3VtOjEwNDcxMDEzNDg%3D> A buyer is interested in your listing Hello Zadoon, A potential buyer has sent you an inquiry regarding an item you have listed for sale. New buyer inquiry for your Caterpillar 770 AC39213F <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> Caterpillar 770, <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> USD Buyer\'s contact details: Fahad aljohani Aljuhani.s.s.co@hotmail.com 0553343168 Message from buyer: Hello give me last price to port The potential buyer has requested to secure the transaction through Ritchie Bros *PurchaseSafe™* service. This service provides verification, ensures a secure payment, and transfers the title. If you decide to sell your equipment to this buyer, you will need to select the *PurchaseSafe™* workflow and fill out the required information in our inventory management system. Learn more <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL3NvbHV0aW9uc2ZvcmRlYWxlcnMuYXNweD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjkwNjY5Njk5Ng%3D%3D> Please respond to the potential buyer at your earliest convenience. Helpful tip: you can update your listing with new information any time. You can view all your leads by logging in to your account. Sincerely, Your Ritchie List Team contact@ritchielist.com';

        email.subject = 'PRICE DROP	 Test';
        email.fromname = 'Test Test2';
        email.fromAddress = 'hardy@zadoon.com.invalid';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'numbers@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Numbers', lead.LeadSource);
        
    }
    @isTest
    public static void testMethod25(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '<https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly9tYWlsLmdvb2dsZS5jb20vbWFpbC91LzAvI21fMTMxMzU0MDc1NjU4NDY4MTI5MV8jZ3Jvb3Zlc3VtOjEwNDcxMDEzNDg%3D> A buyer is interested in your listing Hello Zadoon, A potential buyer has sent you an inquiry regarding an item you have listed for sale. New buyer inquiry for your Caterpillar 770 AC39213F <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> Caterpillar 770, <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL2NvbnN0cnVjdGlvbi9hcnRpY3VsYXRlZC1kdW1wLXRydWNrcy1hcnRpY3VsYXRlZC1kdW1wLXRydWNrL2NhdGVycGlsbGFyLTc3MC9hYzM5MjEzZi1iODEyLTQxNmYtYjUxMC01NjA0Njk1MWQ3YjQuaHRtbD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjMxOTQxMzU%3D> USD Buyer\'s contact details: Fahad aljohani Aljuhani.s.s.co@hotmail.com 0553343168 Message from buyer: Hello give me last price to port The potential buyer has requested to secure the transaction through Ritchie Bros *PurchaseSafe™* service. This service provides verification, ensures a secure payment, and transfers the title. If you decide to sell your equipment to this buyer, you will need to select the *PurchaseSafe™* workflow and fill out the required information in our inventory management system. Learn more <https://groove.grvlnk4.com/url/ll089bgyw887b3q9jpyfjc/aHR0cHM6Ly93d3cucml0Y2hpZWxpc3QuY29tL3NvbHV0aW9uc2ZvcmRlYWxlcnMuYXNweD91dG1fc291cmNlPXRyYW5zYWN0aW9uYWwmdXRtX21lZGl1bT1lbWFpbCZ1dG1fY2FtcGFpZ249cmxfcmVxdWVzdCZ1dG1fY29udGVudD1kZWFsZXIjZ3Jvb3Zlc3VtOjkwNjY5Njk5Ng%3D%3D> Please respond to the potential buyer at your earliest convenience. Helpful tip: you can update your listing with new information any time. You can view all your leads by logging in to your account. Sincerely, Your Ritchie List Team contact@ritchielist.com';

        email.subject = 'PRICE DROP	 Test';
        email.fromname = 'Test Test2';
        email.fromAddress = 'hardy@zadoon.com.invalid';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'wtb@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('WTB', lead.LeadSource);
        
    }
    /*
    @isTest
    public static void testMethod18(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String str = '*Please let us know more about this lead so we can improve the quality of leads we send you:* Name: Patrick Hudson Phone: 2515335747 Email: patrick.h.hudson@icloud.com Message: Product Inquiry Listing:';
        email.subject = 'Test';
        email.fromname = 'Test Test2';
        env.fromAddress = 'fleetupmarketplace@zadoon.com';
        email.plainTextBody = str;
        email.toAddresses = new List<String>{'fleetupmarketplace@zadoon.com'};
        
        Test.startTest();
        Email2Lead emailProcess = new Email2Lead();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        Lead lead = [select Id, Subject__c, LeadSource FROM Lead LIMIT 1];
        System.assert(lead != null);
        System.assertEquals(email.subject, lead.Subject__c);
        System.assertEquals('Zadoon Machinio Leads', lead.LeadSource);
        
    }*/
    
}