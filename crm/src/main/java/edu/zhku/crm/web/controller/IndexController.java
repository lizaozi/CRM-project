package edu.zhku.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author lzw
 * @date 2022/4/17
 * @description
 */
@Controller
public class IndexController {

    //http:127.0.0.1:8080/crm/
    @RequestMapping("/")
    public String index() {
        return "index";
    }
}
