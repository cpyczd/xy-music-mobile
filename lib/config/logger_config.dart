/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-05-22 15:59:47
 * @LastEditTime: 2021-06-01 10:11:47
 */
import 'package:logger/logger.dart';

final log = Logger(
  printer: PrettyPrinter(),
);

void close() {
  log.close();
}
