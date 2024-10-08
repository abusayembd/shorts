import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shorts/controllers/auth_controller.dart';
import 'package:shorts/views/screens/add_video_screen.dart';
import 'package:shorts/views/screens/message_screen.dart';
import 'package:shorts/views/screens/profile_screen.dart';
import 'package:shorts/views/screens/search_screen.dart';
import 'package:shorts/views/screens/video_screen.dart';

List pages = [
  VideoScreen(),
  SearchScreen(),
   const AddVideoScreen(),
  const MessageScreen(),
  ProfileScreen(uid: authController.user.uid),
];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// Strings
const String appName = 'Shorts';


// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;
