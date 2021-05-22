/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:59:47
 * @LastEditTime: 2021-05-22 16:09:07
 */
import 'package:logging/logging.dart';
import 'package:simple_logger/simple_logger.dart';

extension Logger on SimpleLogger {
  void error(message) {
    this.severe(message);
  }
}

final log = SimpleLogger();

///设置日志等级
void setLoggerLavel(Level level) {
  log.setLevel(level);
}
