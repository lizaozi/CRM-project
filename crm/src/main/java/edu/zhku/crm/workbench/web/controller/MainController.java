package edu.zhku.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author lzw
 * @date 2022/4/21
 * @description
 */
@Controller
public class MainController {

    @RequestMapping("/workbench/main/index.do")
    public String index() {
        //跳转
        return "workbench/main/index";
    }
}
