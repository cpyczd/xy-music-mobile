/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-12 11:11:53
 * @LastEditTime: 2021-07-12 11:14:16
 */

class OrmException implements Exception {
  String? actionFun;
  String? message;

  OrmException({
    this.actionFun,
    this.message,
  });

  @override
  String toString() =>
      'OrmException(actionFun: $actionFun, message:  $message)';
}
