import 'package:chatwith/services/navigation_service.dart';
import 'package:flutter/material.dart';

import './search_page.dart';
import './recent_conversations_page.dart';
import './profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late double _deviceHeight;
  late double _deviceWidth;

  late TabController _tabController;

  static const List<Tab> tabList = <Tab>[
    // Tab(icon: Icon(Icons.people_outlined,size: 25)),
    Tab(icon: Icon(Icons.chat_bubble_outline,size: 25)),
    Tab(icon: Icon(Icons.person_outlined,size: 25))
  ];

  _HomePageState(){}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        titleTextStyle: TextStyle(fontSize: 18),
        title: const Text("ChatWith",),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              NavigationService.instance.navigateTo("search");
            }
          )
        ],
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: tabList.map((Tab tab) {
            return tab;
          })!.toList(),),
      ),
      body: _tabBarPages(),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        // SearchPage(_deviceHeight,_deviceWidth),
        RecentConversationsPage(_deviceHeight,_deviceWidth),
        ProfilePage(_deviceHeight,_deviceWidth),
      ]
    );
  }
}