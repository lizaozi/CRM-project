package edu.zhku.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author lzw
 * @date 2022/4/18
 * @description
 */
@Controller
public class WorkbenchIndexController {
    @RequestMapping("/workbench/index.do")
    public String index() {
        //跳转到业务主页面
        return "workbench/index";
    }
}
