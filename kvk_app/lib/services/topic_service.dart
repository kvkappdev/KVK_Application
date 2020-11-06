import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/database_service.dart';

class TopicService {
  final log = getLogger("Topic Service");
  DatabaseService _databaseService = locator<DatabaseService>();
  List<Topic> _topics = List<Topic>();

  Topic _selectedTopic = Topic();

  Future loadTopics() async {
    Topic defaultTopic = Topic();
    defaultTopic.id = "-1";
    defaultTopic.engName = "Uncategorised";
    defaultTopic.marName = "Marathi Uncategorised";
    _topics.add(defaultTopic);
    _selectedTopic = defaultTopic;
    await _databaseService.getTopics().then((value) {
      for (int i = 0; i < value.length; i++) {
        _topics.add(value[i]);
      }
    });
    log.d("Topics: " + _topics.length.toString());
  }

  Future createTopic(
      {@required String engName, @required String marName}) async {
    Topic newTopic = Topic();
    newTopic.engName = engName;
    newTopic.marName = marName;
    await _databaseService.createTopic(topic: newTopic).whenComplete(() {
      _topics.add(newTopic);
    });
  }

  Future removeTopic({@required String name}) async {
    await _databaseService.removeTopic(name: name);
  }

  Topic getTopicByName({@required String name}) {
    for (int i = 0; i < _topics.length; i++) {
      if (_topics[i].engName == name || _topics[i].marName == name) {
        return _topics[i];
      }
    }
    return _topics[0];
  }

  Topic getTopicById({@required String id}) {
    for (int i = 0; i < _topics.length; i++) {
      if (_topics[i].id == id) {
        return _topics[i];
      }
    }
    return _topics[0];
  }

  List<Topic> getTopics() {
    return _topics;
  }

  void setSelectedTopic({@required String topicName}) {
    _selectedTopic = getTopicByName(name: topicName);
  }

  Topic getSelectedTopic() {
    return _selectedTopic;
  }
}
