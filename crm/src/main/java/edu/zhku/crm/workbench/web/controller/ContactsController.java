package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.DicValue;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.settings.service.DicValueService;
import edu.zhku.crm.settings.service.UserService;
import edu.zhku.crm.workbench.domain.Activity;
import edu.zhku.crm.workbench.domain.Contacts;
import edu.zhku.crm.workbench.domain.ContactsRemark;
import edu.zhku.crm.workbench.domain.Tran;
import edu.zhku.crm.workbench.service.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.annotation.RequestScope;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/17
 * @description
 */
@Controller
public class ContactsController {

    @Resource
    private UserService userService;
    @Resource
    private DicValueService dicValueService;
    @Resource
    private ContactsService contactsService;
    @Resource
    private CustomerService customerService;
    @Resource
    private ContactsRemarkService contactsRemarkService;
    @Resource
    private TranService tranService;
    @Resource
    private ActivityService activityService;

    /**
     * 跳转客户主页面，并且查询用户、来源和称呼
     * @param request
     * @return
     */
    @RequestMapping("/workbench/contacts/toIndex.do")
    public String toIndex(HttpServletRequest request) {
        //查询用户
        List<User> userList = userService.queryAllUsers();
        //查询来源
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        //查询称呼
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");

        //保存到request
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);

        //跳转页面
        return "workbench/contacts/index";

    }

    /**
     * 根据条件查询联系人，并且进行分页处理
     * @param
     * @return
     */
    @RequestMapping("/workbench/contacts/queryContactsByConditionForPage.do")
    @ResponseBody
    public Object queryContactsByConditionForPage(String owner,String fullname,String customerName,String source,
                                                  int pageNo,int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("owner",owner);
        map.put("fullname",fullname);
        map.put("customerName",customerName);
        map.put("source",source);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);

        //调用service
        List<Contacts> contactsList = contactsService.queryContactsByConditionForPage(map);
        int totalRows = contactsService.queryCountOfContactsByConditionForPage(map);

        //返回数据
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("contactsList",contactsList);
        retMap.put("totalRows",totalRows);

        return retMap;
    }

    /**
     * 根据客户名字模糊查询客户全名，用于自动补全功能
     * @param customerName
     * @return
     */
    @RequestMapping("/workbench/contacts/queryAllCustomerName.do")
    @ResponseBody
    public Object queryAllCustomerName(String customerName) {
        //调用service，查询数据
        List<String> customerNameList = customerService.queryAllCustomerNameByName(customerName);
        //返回数据
        return customerNameList;
    }

    /**
     * 创建联系人
     * @param map
     * @param session
     * @return
     */
    @RequestMapping("/workbench/contacts/saveCreateContacts.do")
    @ResponseBody
    public Object saveCreateContacts(@RequestParam Map<String,Object> map, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        map.put(Constants.SESSION_USER,user);

        ReturnObject returnObject = new ReturnObject();
        try {
            //插入数据
            contactsService.saveCreateContacts(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 根据联系人id单个或多个删除联系人
     * @param id
     * @return
     */
    @RequestMapping("/workbench/contacts/deleteContactsByIds.do")
    @ResponseBody
    public Object deleteContactsByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，删除联系人
            int result = contactsService.deleteContactsByIds(id);
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
     * 根据id查询联系人信息，用于修改页面回显数据
     * @param id
     * @return
     */
    @RequestMapping("/workbench/contacts/queryContactsById.do")
    @ResponseBody
    public Object queryContactsById(String id) {
        //查询
        Contacts contacts = contactsService.queryContactsById(id);
        return contacts;
    }



    /**
     * 根据id修改联系人信息
     * @param map
     * @param session
     * @return
     */
    @RequestMapping("/workbench/contacts/saveEditContacts.do")
    @ResponseBody
    public Object saveEditContacts(@RequestParam Map<String,Object> map,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        map.put(Constants.SESSION_USER,user);

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，修改
            contactsService.saveEditContacts(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 处理联系人详细信息
     * @param id
     * @return
     */
    @RequestMapping("/workbench/contacts/detailContacts.do")
    public String  detailContacts(String id,HttpServletRequest request) {
        //查询联系人信息
        Contacts contacts = contactsService.queryContactsByIdForDetail(id);
        //查询联系人备注信息
        List<ContactsRemark> contactsRemarkList = contactsRemarkService.queryContactsRemarkByContactsIdForDetail(id);
        //查询关联的交易信息
        List<Tran> tranList = tranService.queryTranByContactsIdForDetail(id);
        //查询关联的市场活动
        List<Activity> activityList = activityService.queryActivityByContactsIdForDetail(id);

        //保存到request
        request.setAttribute("contacts",contacts);
        request.setAttribute("contactsRemarkList",contactsRemarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("activityList",activityList);

        //跳转
        return "workbench/contacts/detail";
    }
}
