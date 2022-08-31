package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.domain.DicValue;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.settings.service.DicValueService;
import edu.zhku.crm.settings.service.UserService;
import edu.zhku.crm.workbench.domain.*;
import edu.zhku.crm.workbench.service.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
@Controller
public class TranController {

    @Resource
    private UserService userService;
    @Resource
    private DicValueService dicValueService;
    @Resource
    private TranService tranService;
    @Resource
    private ActivityService activityService;
    @Resource
    private ContactsService contactsService;
    @Resource
    private CustomerService customerService;
    @Resource
    private TranRemarkService tranRemarkService;
    @Resource
    private TranHistoryService tranHistoryService;

    /**
     * 跳转交易主页
     * @param request
     * @return
     */
    @RequestMapping("/workbench/transaction/index.do")
    public String index(HttpServletRequest request) {
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> tranTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");

        //保存
        request.setAttribute("stageList",stageList);
        request.setAttribute("tranTypeList",tranTypeList);
        request.setAttribute("sourceList",sourceList);
        //跳转
        return "workbench/transaction/index";
    }

    /**
     * 根据条件进行查询交易信息，并且分页处理
     * @param owner
     * @param name
     * @param customerId
     * @param stage
     * @param type
     * @param source
     * @param contactsId
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/workbench/transaction/queryTranByConditionForPage.do")
    @ResponseBody
    public Object queryTranByConditionForPage(String owner,String name,String customerId,String stage,
                                              String type,String source,String contactsId,int pageNo,
                                              int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("owner",owner);
        map.put("name",name);
        map.put("customerId",customerId);
        map.put("stage",stage);
        map.put("type",type);
        map.put("source",source);
        map.put("contactsId",contactsId);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //调用service，查询交易数据
        List<Tran> tranList = tranService.queryTranByConditionForPage(map);
        //查询条数
        int totalRows = tranService.queryCountOfTranByConditionForPage(map);

        //返回数据
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("tranList",tranList);
        retMap.put("totalRows",totalRows);

        return retMap;
    }

    /**
     * 请求转发到创建交易页面
     * @param request
     * @return
     */
    @RequestMapping("/workbench/transaction/toSave.do")
    public String toSave(HttpServletRequest request) {
        //获取下拉列表内容
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> tranTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        //保存到request
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("tranTypeList",tranTypeList);
        request.setAttribute("sourceList",sourceList);

        //请求转发
        return "workbench/transaction/save";
    }

    /**
     * 根据市场活动名称模糊查询市场活动，用于创建交易
     * @param activityName
     * @return
     */
    @RequestMapping("/workbench/transaction/queryActivityForCreateTran.do")
    @ResponseBody
    public Object queryActivityForCreateTran(String activityName) {
        //查询数据
        List<Activity> activityList = activityService.queryActivityByName(activityName);
        //返回数据
        return activityList;
    }

    /**
     * 根据联系人名称模糊查询，用于创建交易
     * @param contactsName
     * @return
     */
    @RequestMapping("/workbench/transaction/queryContactsForCreateTran.do")
    @ResponseBody
    public Object queryContactsForCreateTran(String contactsName) {
        //查询
        List<Contacts> contactsList = contactsService.queryContactsByName(contactsName);
        //返回
        return contactsList;
    }

    /**
     * 根据阶段选择可能性
     * @param stageValue
     * @return
     */
    @RequestMapping("/workbench/transaction/getPossibilityByStageValue.do")
    @ResponseBody
    public Object getPossibilityByStageValue(String stageValue) {
        //解析properties
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stageValue);
        //返回
        return possibility;
    }

    /**
     * 根据客户名字模糊查询客户全名，用于自动补全功能
     * @param customerName
     * @return
     */
    @RequestMapping("/workbench/transaction/queryAllCustomerName.do")
    @ResponseBody
    public Object queryAllCustomerName(String customerName) {
        //调用service，查询数据
        List<String> customerNameList = customerService.queryAllCustomerNameByName(customerName);
        //返回数据
        return customerNameList;
    }

    /**
     * 保存创建交易
     * @param map
     * @param session
     * @return
     */
    @RequestMapping("/workbench/transaction/saveCreateTran.do")
    @ResponseBody
    public Object saveCreateTran(@RequestParam Map<String,Object> map, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        map.put(Constants.SESSION_USER,user);

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存创建交易
            tranService.saveCreateTran(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 查看交易详情
     * @param tranId
     * @param request
     * @return
     */
    @RequestMapping("/workbench/transaction/tranDetail.do")
    public String tranDetail(String tranId,HttpServletRequest request) {
        //查询交易信息
        Tran tran = tranService.queryTranByIdForDetail(tranId);
        //查询交易备注信息
        List<TranRemark> tranRemarkList = tranRemarkService.queryTranRemarkByIdForDetail(tranId);
        //查询交易历史记录
        List<TranHistory> tranHistoryList = tranHistoryService.queryTranHistoryByTranIdForDetail(tranId);
        //查询可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(tran.getStage());
        //request
        request.setAttribute("tran",tran);
        request.setAttribute("tranRemarkList",tranRemarkList);
        request.setAttribute("tranHistoryList",tranHistoryList);
        request.setAttribute("possibility",possibility);

        //查询阶段列表，用于交易图标
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("stageList",stageList);
        //请求转发
        return "workbench/transaction/detail";
    }

}
