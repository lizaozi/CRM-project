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
import edu.zhku.crm.workbench.domain.Clue;
import edu.zhku.crm.workbench.domain.ClueActivityRelation;
import edu.zhku.crm.workbench.domain.ClueRemark;
import edu.zhku.crm.workbench.service.ActivityService;
import edu.zhku.crm.workbench.service.ClueActivityRelationService;
import edu.zhku.crm.workbench.service.ClueRemarkService;
import edu.zhku.crm.workbench.service.ClueService;
import org.aspectj.apache.bcel.classfile.Constant;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author lzw
 * @date 2022/4/29
 * @description
 */
@Controller
public class ClueController {
    @Resource
    private UserService userService;
    @Resource
    private DicValueService dicValueService;
    @Resource
    private ClueService clueService;
    @Resource
    private ClueRemarkService clueRemarkService;
    @Resource
    private ActivityService activityService;
    @Resource
    private ClueActivityRelationService clueActivityRelationService;

    /**
     * 跳转到线索主页面，并且查询所有用于创建线索时的下拉列表的信息,保存到request中
     * @param request
     * @return
     */
    @RequestMapping("/workbench/clue/index.do")
    public String index(HttpServletRequest request) {
        //调用service，查询所有用户信息
        List<User> userList = userService.queryAllUsers();
        //查询所有称呼
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");
        //查询所有线索状态
        List<DicValue> clueStateList = dicValueService.queryDicValueByTypeCode("clueState");
        //查询所有来源
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");

        //保存到request
        request.setAttribute("userList",userList);
        request.setAttribute("appellationList",appellationList);
        request.setAttribute("clueStateList",clueStateList);
        request.setAttribute("sourceList",sourceList);
        //跳转线索主页
        return "workbench/clue/index";
    }

    /**
     * 创建线索
     * @param clue
     * @param session
     * @return
     */
    @RequestMapping("/workbench/clue/saveCreateClue.do")
    @ResponseBody
    public Object saveCreateClue(Clue clue, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        clue.setId(UUIDUtils.getUUID());
        clue.setCreateTime(DateUtils.formatDateTime(new Date()));
        clue.setCreateBy(user.getId());

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存数据
            int result = clueService.saveCreateClue(clue);
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
     * 根据线索条件进行查询并且进行处理分页
     * @param fullname
     * @param company
     * @param phone
     * @param source
     * @param owner
     * @param mphone
     * @param state
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/workbench/clue/queryClueByConditionForPage.do")
    @ResponseBody
    public Object queryClueByConditionForPage(String fullname,String company,String phone,String source,
                                              String owner,String mphone,String state,int pageNo,int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("fullname",fullname);
        map.put("company",company);
        map.put("phone",phone);
        map.put("source",source);
        map.put("owner",owner);
        map.put("mphone",mphone);
        map.put("state",state);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);

        //查询线索和条数
        List<Clue> clueList = clueService.queryAllClueByConditionForPage(map);
        int totalRows = clueService.queryCountOfClueByCondition(map);

        //生成响应信息
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("clueList",clueList);
        retMap.put("totalRows",totalRows);

        //返回结果
        return retMap;
    }

    /**
     * 根据id删除线索及其线索备注信息和市场活动关联信息
     * @param id
     * @return
     */
    @RequestMapping("/workbench/clue/deleteClueByIds.do")
    @ResponseBody
    public Object deleteClueByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，删除线索及其线索备注信息和市场活动关联信息
            clueService.deleteClueByIds(id);
            //成功
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 根据id查询线索信息，用于页面数据回显
     * @param id
     * @return
     */
    @RequestMapping("/workbench/clue/queryClueById.do")
    @ResponseBody
    public Object queryClueById(String id) {
        Clue clue = clueService.queryClueById(id);
        //返回数据
        return clue;
    }

    /**
     * 保存修改后的线索
     * @param clue
     * @param session
     * @return
     */
    @RequestMapping("/workbench/clue/saveEditClue.do")
    @ResponseBody
    public Object saveEditClue(Clue clue,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        clue.setEditTime(DateUtils.formatDateTime(new Date()));
        clue.setEditBy(user.getId());

        ReturnObject returnObject = new ReturnObject();
        try {
            //修改数据
            int result = clueService.editClueById(clue);
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
     * 处理线索详细信息页面
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/workbench/clue/detailClue.do")
    public String detailClue(String id,HttpServletRequest request) {
        //查询线索数据
        Clue clue = clueService.queryClueByIdForDetail(id);
        //查询备注信息
        List<ClueRemark> remarkList = clueRemarkService.queryClueRemarkByClueIdForDetail(id);
        //查询关联的市场活动信息
        List<Activity> activityList = activityService.queryActivityByClueIdForDetail(id);

        //保存到request
        request.setAttribute("clue",clue);
        request.setAttribute("remarkList",remarkList);
        request.setAttribute("activityList",activityList);
        //请求转发
        return "workbench/clue/detail";
    }

    /**
     * 根据市场活动名称查询市场活动，并且把已经和clueId关联过的排除，用于关联市场活动
     * @param activityName
     * @param clueId
     * @return
     */
    @RequestMapping("/workbench/clue/queryActivityForDetailByNameClueId.do")
    @ResponseBody
    public Object queryActivityForDetailByNameClueId(String activityName,String clueId) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("activityName",activityName);
        map.put("clueId",clueId);
        //调用service查询
        List<Activity> activityList = activityService.queryActivityForDetailByNameClueId(map);
        //返回
        return activityList;
    }

    /**
     * 保存关联信息
     * @param activityId
     * @param clueId
     * @return
     */
    @RequestMapping("/workbench/clue/saveBund.do")
    @ResponseBody
    public Object saveBund(String[] activityId,String clueId) {
        //封装参数
        List<ClueActivityRelation> relationList = new ArrayList<>();
        ClueActivityRelation car = null;
        for (String ac:activityId) {
            car = new ClueActivityRelation();

            car.setId(UUIDUtils.getUUID());
            car.setClueId(clueId);
            car.setActivityId(ac);

            relationList.add(car);
        }
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存关联信息
            int result = clueActivityRelationService.saveActivityRelationByList(relationList);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);

                //保存成功，根据线索id查询关联的市场活动的信息
                List<Activity> activityList = activityService.queryActivityByClueIdForDetail(clueId);
                returnObject.setRetData(activityList);
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
     * 解除关联关系
     * @param relation
     * @return
     */
    @RequestMapping("/workbench/clue/removeClueActivityRelation.do")
    @ResponseBody
    public Object removeClueActivityRelation(ClueActivityRelation relation) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，删除关联
            int result = clueActivityRelationService.deleteClueActivityRelationByClueIdActivityId(relation);
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
     * 查询线索详细信息以及阶段下拉列表的数据，跳转到convert.jsp页面
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/workbench/clue/toConvert.do")
    public String toConvert(String id,HttpServletRequest request) {
        //调用service，查询线索详细信息
        Clue clue = clueService.queryClueByIdForDetail(id);
        //查询阶段下拉列表的数据
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        //保存到request中
        request.setAttribute("clue",clue);
        request.setAttribute("stageList",stageList);
        //请求转发
        return "workbench/clue/convert";
    }

    /**
     * 根据市场活动名称模糊查询，并且该市场活动是已经跟线索关联过的，用于线索转换是创建业务功能
     * @param activityName
     * @param clueId
     * @return
     */
    @RequestMapping("/workbench/clue/queryActivityForConvertByNameClueId.do")
    @ResponseBody
    public Object queryActivityForConvertByNameClueId(String activityName,String clueId) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("activityName",activityName);
        map.put("clueId",clueId);
        //调用service，查询数据
        List<Activity> activityList = activityService.queryActivityForConvertByNameClueId(map);
        //返回信息
        return activityList;
    }

    /**
     * 线索转换
     * @return
     */
    @RequestMapping("/workbench/clue/saveConvertClue.do")
    @ResponseBody
    public Object saveConvertClue(String clueId,String money,String name,String expectedDate,
                                  String stage,String activityId,String isCreateTran,HttpSession session) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("clueId",clueId);
        map.put(Constants.SESSION_USER,session.getAttribute(Constants.SESSION_USER));
        map.put("money",money);
        map.put("name",name);
        map.put("expectedDate",expectedDate);
        map.put("stage",stage);
        map.put("activityId",activityId);
        map.put("isCreateTran",isCreateTran);

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，保存数据
            clueService.saveConvertClue(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }
}
