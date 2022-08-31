package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.workbench.domain.CustomerRemark;
import edu.zhku.crm.workbench.service.CustomerRemarkService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.Date;

/**
 * @author lzw
 * @date 2022/5/9
 * @description
 */
@Controller
public class CustomerRemarkController {

    @Resource
    private CustomerRemarkService customerRemarkService;

    /**
     * 保存客户备注信息
     * @param
     * @param
     * @return
     */
    @RequestMapping("/workbench/customer/saveCustomerRemark.do")
    @ResponseBody
    public Object saveCustomerRemark(CustomerRemark customerRemark, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        customerRemark.setId(UUIDUtils.getUUID());
        customerRemark.setCreateBy(user.getId());
        customerRemark.setCreateTime(DateUtils.formatDateTime(new Date()));
        customerRemark.setEditFlag("0");

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，插入数据
            int result = customerRemarkService.saveCustomerRemark(customerRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(customerRemark);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 根据id删除客户备注
     * @param id
     * @return
     */
    @RequestMapping("/workbench/customer/deleteCustomerRemark.do")
    @ResponseBody
    public Object deleteCustomerRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service
            int result = customerRemarkService.deleteCustomerRemarkById(id);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 修改客户备注信息
     * @param remark
     * @param session
     * @return
     */
    @RequestMapping("/workbench/customer/editCustomerRemark.do")
    @ResponseBody
    public Object editCustomerRemark(CustomerRemark remark,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        remark.setEditBy(user.getId());
        remark.setEditTime(DateUtils.formatDateTime(new Date()));
        remark.setEditFlag("1");

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service
            int result = customerRemarkService.editCustomerRemarkById(remark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(remark);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }
}
