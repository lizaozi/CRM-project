package edu.zhku.crm.settings.web.interceptor;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.domain.User;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * @author lzw
 * @date 2022/4/20
 * @description 拦截器
 */
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o) throws Exception {
        //如果用户没有登录，则跳转到登录页面
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        if (user == null) {
            //重定向
            httpServletResponse.sendRedirect(httpServletRequest.getContextPath());//重定向，url必须要带项目名
            return false;
        }
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) throws Exception {

    }
}
