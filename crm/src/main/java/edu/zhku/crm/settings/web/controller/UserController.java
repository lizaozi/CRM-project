package edu.zhku.crm.settings.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/4/17
 * @description
 */
@Controller
public class UserController {
    @Resource
    private UserService userService;

    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin() {
        return "settings/qx/user/login";
    }

    @RequestMapping("/settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpServletResponse response,HttpSession session) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);

        //调用service层方法
        User user = userService.queryUserByLoginActAndPwd(map);

        //根据查询结果，生成响应信息
        ReturnObject returnObject = new ReturnObject();
        if (user == null) {
            //登录失败，用户名或者密码错误
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户名或密码错误！");
        }else { //进一步判断是否合法
            //格式化date
            String nowStr = DateUtils.formatDateTime(new Date());
            if (nowStr.compareTo(user.getExpireTime()) > 0) {
                //登录失败，账号已过期
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号已过期！");
            }else if("0".equals(user.getLockState())) {
                //登录失败，账号已锁定
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号状态已锁定！");
            }else if(!user.getAllowIps().contains(request.getRemoteAddr())) {
                //登录失败，ip受限
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("ip受限！");
            }else {
                //登录成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                //把user保存到session中
                session.setAttribute(Constants.SESSION_USER,user);

                //如果需要记住密码，则往外写cookie
                if ("true".equals(isRemPwd)) {
                    Cookie c1 = new Cookie("loginAct",user.getLoginAct());
                    c1.setMaxAge(10*24*60*60);
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd",user.getLoginPwd());
                    c2.setMaxAge(10*24*60*60);
                    response.addCookie(c2);
                }else {
                    //把没有过期的cookie删除
                    Cookie c1 = new Cookie("loginAct","1");
                    c1.setMaxAge(0);
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd","1");
                    c2.setMaxAge(0);
                    response.addCookie(c2);
                }
            }
        }
        return returnObject;
    }

    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpServletResponse response,HttpSession session) {
        //清除cookie
        Cookie c1 = new Cookie("loginAct","1");
        c1.setMaxAge(0);
        response.addCookie(c1);
        Cookie c2 = new Cookie("loginPwd","1");
        c2.setMaxAge(0);
        response.addCookie(c2);
        //清除session
        session.invalidate();

        //重定向
        return "redirect:/";//借助springmvc来重定向，底层代码：response.sendRedirect("/crm/")
    }
}
