package edu.zhku.crm.workbench.web.controller;

import com.sun.tools.internal.jxc.ap.Const;
import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.DicValue;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.settings.service.DicValueService;
import edu.zhku.crm.settings.service.UserService;
import edu.zhku.crm.workbench.domain.Contacts;
import edu.zhku.crm.workbench.domain.Customer;
import edu.zhku.crm.workbench.domain.CustomerRemark;
import edu.zhku.crm.workbench.domain.Tran;
import edu.zhku.crm.workbench.mapper.CustomerMapper;
import edu.zhku.crm.workbench.service.ContactsService;
import edu.zhku.crm.workbench.service.CustomerRemarkService;
import edu.zhku.crm.workbench.service.CustomerService;
import edu.zhku.crm.workbench.service.TranService;
import org.aspectj.apache.bcel.classfile.Constant;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author lzw
 * @date 2022/5/5
 * @description
 */
@Controller
public class CustomerController {

    @Resource
    private UserService userService;
    @Resource
    private CustomerService customerService;
    @Resource
    private CustomerRemarkService customerRemarkService;
    @Resource
    private TranService tranService;
    @Resource
    private ContactsService contactsService;
    @Resource
    private DicValueService dicValueService;


    /**
     * 跳转到客户主页面，并查询所有者，用于创建客户时使用
     * @return
     */
    @RequestMapping("/workbench/customer/index.do")
    public String index(HttpServletRequest request) {
        List<User> userList = userService.queryAllUsers();
        //保存到request
        request.setAttribute(Constants.SESSION_USER,userList);
        //跳转
        return "workbench/customer/index";
    }

    /**
     * 根据条件查询客户数据和条数，并且进行分页
     * @param name
     * @param owner
     * @param phone
     * @param website
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/workbench/customer/queryCustomerByConditionForPage.do")
    @ResponseBody
    public Object queryCustomerByConditionForPage(String name,String owner,String phone,String website,
                                                  int pageNo,int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("beginNo",(pageNo - 1)*pageSize);
        map.put("pageSize",pageSize);

        //调用service，查询数据和条数
        List<Customer> customerList = customerService.queryCustomerByConditionForPage(map);
        int totalRows = customerService.queryCountOfCustomerByCondition(map);

        //根据生成结果，生成响应信息
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("customerList",customerList);
        retMap.put("totalRows",totalRows);

        //返回数据
        return retMap;
    }

    /**
     * 创建客户
     * @param customer
     * @param session
     * @return
     */
    @RequestMapping("/workbench/customer/saveCreateCustomer.do")
    @ResponseBody
    public Object saveCreateCustomer(Customer customer, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        customer.setId(UUIDUtils.getUUID());
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtils.formatDateTime(new Date()));

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存数据
            int result = customerService.saveCustomer(customer);
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
     * 根据id单条或批量删除客户信息及其备注、交易和联系人信息
     * @param id
     * @return
     */
    @RequestMapping("/workbench/customer/deleteCustomerByIds.do")
    @ResponseBody
    public Object deleteCustomerByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，删除数据
            int result = customerService.deleteCustomerByIds(id);
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
     * 根据id查询客户信息，用于信息回显
     * @param id
     * @return
     */
    @RequestMapping("/workbench/customer/queryCustomerById.do")
    @ResponseBody
    public Object queryCustomerById(String id) {
        //调用service，查询数据
        Customer customer = customerService.queryCustomerById(id);
        //返回数据
        return customer;
    }

    /**
     * 保存修改后的客户信息
     * @param customer
     * @param session
     * @return
     */
    @RequestMapping("/workbench/customer/saveEditCustomer.do")
    @ResponseBody
    public Object saveEditCustomer(Customer customer,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        customer.setEditBy(user.getId());
        customer.setEditTime(DateUtils.formatDateTime(new Date()));

        ReturnObject returnObject = new ReturnObject();
        try {
            //修改数据
            int result = customerService.editCustomerById(customer);
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
     * 处理客户详细信息
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/workbench/customer/detailCustomer.do")
    public String detailCustomer(String id,HttpServletRequest request) {
        //查询客户详细信息
        Customer customer = customerService.queryCustomerByIdForDetail(id);
        //查询客户备注信息
        List<CustomerRemark> remarkList = customerRemarkService.queryCustomerRemarkByCustomerIdForDetail(id);
        //查询交易信息
        List<Tran> tranList = tranService.queryTranByCustomerIdForDetail(id);
        //查询联系人信息
        List<Contacts> contactsList = contactsService.queryContactsByCustomerIdForDetail(id);
        //查询所有用户信息
        List<User> userList = userService.queryAllUsers();
        //查询阶段
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        //查询类型
        List<DicValue> typeList = dicValueService.queryDicValueByTypeCode("transactionType");
        //查询来源
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        //查询称呼
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");

        //保存到request
        request.setAttribute("customer",customer);
        request.setAttribute("remarkList",remarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("contactsList",contactsList);
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("typeList",typeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);

        //跳转
        return "workbench/customer/detail";
    }

    /**
     * 删除客户详情中的交易
     * @param id
     * @return
     */
    @RequestMapping("/workbench/customer/deleteTran.do")
    @ResponseBody
    public Object deleteTran(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service
            int result = tranService.deleteTranById(id);
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
     * 保存添加联系人
     * @param contacts
     * @param session
     * @return
     */
    @RequestMapping("/workbench/customer/saveContacts.do")
    @ResponseBody
    public Object saveContacts(Contacts contacts,HttpSession session) {
        //封装参数
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        contacts.setId(UUIDUtils.getUUID());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateUtils.formatDateTime(new Date()));

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存
            int result = contactsService.saveContacts(contacts);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(contacts);
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
     * 根据联系人id删除联系人
     * @param id
     * @return
     */
    @RequestMapping("/workbench/customer/deleteContactsById.do")
    @ResponseBody
    public Object deleteContactsById(String id) {
        ReturnObject returnObject = new ReturnObject();

        try {
            //删除
            int result = contactsService.deleteContactsById(id);
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
}
