/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-01 13:35:42
 * @LastEditTime: 2021-06-01 14:12:08
 */

abstract class BaseEntity {
  int? id;
  Map<String, dynamic> toMap();
}
