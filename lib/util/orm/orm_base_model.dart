/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 13:35:42
 * @LastEditTime: 2021-07-11 19:33:44
 */

abstract class OrmBaseModel {
  int? id;
  Map<String, dynamic> toMap();
}
