import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DatabaseProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: Color.fromARGB(255, 0, 187, 44),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: LoginPage(),
          ),
        ),
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _model = LoginModel();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      return ChatPage();
    }
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Center(
          child: Text('FlutterZap'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(email)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (email) {
                  _model = _model.copyWith(email: email);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (password.length < 6) {
                    return 'Please enter a password with at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
                onSaved: (password) {
                  _model = _model.copyWith(password: password);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();
                  if (_formKey.currentState?.validate() == true) {
                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: _model.email,
                        password: _model.password,
                      );
                      final database = FirebaseDatabase.instance;

                      await database
                          .ref()
                          .child('users')
                          .child(credential.user!.uid)
                          .set({
                        'email': credential.user!.email,
                      });
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid login.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class LoginModel {
  final String email;
  final String password;

  const LoginModel({
    this.email = '',
    this.password = '',
  });

  LoginModel copyWith({
    String? email,
    String? password,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

// Página de chat do aplicativo
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Bem vindo!'),
            subtitle: Text('Você ainda não possui contatos!'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Botão para navegar para a página de contatos
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContactPage(),
            ),
          );
        },
        child: Icon(Icons.message),
      ),
    );
  }
}

// Provedor de autenticação
class AuthProvider extends ChangeNotifier {
  User? _user;

  AuthProvider() {
    // Ouça as alterações no estado de autenticação
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isAuthenticated => user != null;
}

// Página de contatos do aplicativo
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    if (databaseProvider.users == '{}') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Contatos'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Obtenha a lista de usuários do provedor de banco de dados
    Map<String, dynamic> users = jsonDecode(databaseProvider.users);
    List<Map<String, String>> userList = [];

    users.forEach((uid, details) {
      userList.add({
        'uid': uid,
        'email': details['email'],
      });
    });

    // Remova o usuário atual da lista de contatos
    userList.removeWhere(
        (user) => user['uid'] == FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
      ),
      body: Center(
          child: ListView(
        children: userList.map((user) {
          return ListTile(
            title: Text(user['email']!),
            onTap: () {
              // Navegue para a página de detalhes da mensagem ao tocar em um contato
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MessageDetails(
                    uid: user['uid']!,
                    email: user['email']!,
                  ),
                ),
              );
            },
          );
        }).toList(),
      )),
    );
  }
}

// Provedor de banco de dados
class DatabaseProvider extends ChangeNotifier {
  String _users = '{}';

  DatabaseProvider() {
    // Ouça as alterações no estado de autenticação
    FirebaseDatabase.instance.ref().child('users').onValue.listen((event) {
      _users = jsonEncode(event.snapshot.value);
      notifyListeners();
    });
  }

  String get users => _users;
}

class MessageDetails extends StatefulWidget {
  final String uid;
  final String email;

  const MessageDetails({
    super.key,
    required this.uid,
    required this.email,
  });

  @override
  State<MessageDetails> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('messages')
                    .child(
                        '${FirebaseAuth.instance.currentUser!.uid}_${widget.uid}')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> messages = jsonDecode(
                        jsonEncode(snapshot.data!.snapshot.value ?? {}));
                    List<Map<String, String>> messageList = [];

                    messages.forEach((uid, details) {
                      messageList.add({
                        'uid': uid,
                        'message': details['message'],
                        'sender': details['sender'],
                        'email': details['email'],
                      });
                    });

                    return ListView(
                      children: messageList.map((message) {
                        final isCurrentUser = message['sender'] ==
                            FirebaseAuth.instance.currentUser!.uid;
                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Color.fromARGB(255, 128, 225, 188)
                                : Color.fromARGB(255, 180, 181, 181),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              message['message']!,
                              textAlign: isCurrentUser
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 76, 76, 76),
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              message['email']!,
                              textAlign: isCurrentUser
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 76, 76, 76),
                                fontSize: 8,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Message',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    onPressed: () async {
                      await FirebaseDatabase.instance
                          .ref()
                          .child('messages')
                          .child(
                              '${FirebaseAuth.instance.currentUser!.uid}_${widget.uid}')
                          .push()
                          .set({
                        'message': textController.text,
                        'sender': FirebaseAuth.instance.currentUser!.uid,
                        'email': FirebaseAuth.instance.currentUser!.email,
                      });
                      await FirebaseDatabase.instance
                          .ref()
                          .child('messages')
                          .child(
                              '${widget.uid}_${FirebaseAuth.instance.currentUser!.uid}')
                          .push()
                          .set({
                        'message': textController.text,
                        'sender': FirebaseAuth.instance.currentUser!.uid,
                        'email': FirebaseAuth.instance.currentUser!.email,
                      });
                      textController.clear();
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
