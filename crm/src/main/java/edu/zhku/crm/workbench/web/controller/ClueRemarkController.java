package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.workbench.domain.ClueRemark;
import edu.zhku.crm.workbench.service.ClueRemarkService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.Date;

/**
 * @author lzw
 * @date 2022/5/3
 * @description
 */
@Controller
public class ClueRemarkController {
    @Resource
    private ClueRemarkService clueRemarkService;

    /**
     * 添加线索备注
     * @param clueRemark
     * @param session
     * @return
     */
    @RequestMapping("/workbench/clue/saveClueRemark.do")
    @ResponseBody
    public Object saveClueRemark(ClueRemark clueRemark, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        clueRemark.setId(UUIDUtils.getUUID());
        clueRemark.setCreateBy(user.getId());
        clueRemark.setCreateTime(DateUtils.formatDateTime(new Date()));
        clueRemark.setEditFlag("0");

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，添加备注
            int result = clueRemarkService.saveClueRemark(clueRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(clueRemark);
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
     * 删除线索备注信息
     * @param id
     * @return
     */
    @RequestMapping("/workbench/clue/deleteClueRemark.do")
    @ResponseBody
    public Object deleteClueRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，删除备注
            int result = clueRemarkService.deleteClueRemarkById(id);
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
     * 根据线索备注id修改备注信息
     * @param clueRemark
     * @param session
     * @return
     */
    @RequestMapping("/workbench/clue/editClueRemark.do")
    @ResponseBody
    public Object editClueRemark(ClueRemark clueRemark,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        clueRemark.setEditBy(user.getId());
        clueRemark.setEditTime(DateUtils.formatDateTime(new Date()));
        clueRemark.setEditFlag("1");

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service，修改备注
            int result = clueRemarkService.editClueRemark(clueRemark);
            if (result > 0 ) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(clueRemark);
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
