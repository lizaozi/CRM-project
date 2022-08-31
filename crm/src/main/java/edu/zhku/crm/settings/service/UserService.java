package edu.zhku.crm.settings.service;

import edu.zhku.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/4/18
 * @description
 */
public interface UserService {
    /**
     * 根据用户名和密码查询用户
     * @param map
     * @return
     */
    User queryUserByLoginActAndPwd(Map<String,Object> map);

    /**
     * 查询所有用户
     * @return
     */
    List<User> queryAllUsers();
}
