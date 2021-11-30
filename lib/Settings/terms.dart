import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TermsAndCondition extends StatefulWidget {
  TermsAndCondition({Key key}) : super(key: key);
  @override
  _TermsAndConditionState createState() => new _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
           iconTheme: IconThemeData(color: Colors.white),
           backgroundColor: Color(0xFFA41D21),          title: new Text('Terms and Conditions'),
          ),
          body:CustomScrollView(
  shrinkWrap: true,
  slivers: <Widget>[
    SliverPadding(
      padding: const EdgeInsets.all(20.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          <Widget>[
            CircleAvatar( backgroundColor: Color(0xFFA41D21), radius: 75, child: Image.asset("assets/new_logo.png"),),
             SizedBox(height: 15,),
            const Text( "Red FootPrint Affiliate Program Terms of Service",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,), 
             SizedBox(height: 15,),
                       const Text('Agreement',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                      SizedBox(height: 10,),
            const Text('By signing up to be an Affiliate in the Red FootPrint Affiliate Program (“Program”) you are agreeing to be bound by the following terms and conditions (“Terms of Service”).'),
             SizedBox(height: 10,),
            const Text('Red FootPrint reserves the right to update and change the Terms of Service from time to time without notice. Any new features that augment or enhance the current Program, including the release of new tools and resources, shall be subject to the Terms of Service. Continued use of the Program after any such changes shall constitute your consent to such changes.'),
             SizedBox(height: 10,),
             const Text('Violation of any of the terms below will result in the termination of your Account and for forfeiture of any outstanding affiliate commission payments earned during the violation. You agree to use the Affiliate Program at your own risk.'),
                SizedBox(height: 10,),
   const Text('Account Terms',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                      SizedBox(height: 10,),
                         const Text('You must be 18 years or older to be part of this Program'),
                            const Text('You must live in the United States to be an Affiliate.'),
                               const Text('You must be a human. Accounts registered by “bots” or other automated methods are not permitted.'),
                                  const Text('Your login may only be used by one person – a single login shared by multiple people is not permitted.'),
                                        const Text('Your login may only be used by one person – a single login shared by multiple people is not permitted.'),
                                           const Text('You are responsible for all Content posted and activity that occurs under your account.'),
                                              const Text('One person or legal entity may not maintain more than one account.'),
                                                 const Text('You may not use the Affiliate Program for any illegal or unauthorized purpose. You must not, in the use of the Service, violate any laws in your jurisdiction (including but not limited to copyright laws).'),
                                                    const Text('You may not use the Affiliate Program to earn money on your own Red FootPrint product accounts.'),

          ],
        ),
      ),
    ),
  ],
) ,
      );
    }
}