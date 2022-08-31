package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.domain.ReturnObject;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.HSSFUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.settings.service.UserService;
import edu.zhku.crm.workbench.domain.Activity;
import edu.zhku.crm.workbench.domain.ActivityRemark;
import edu.zhku.crm.workbench.service.ActivityRemarkService;
import edu.zhku.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

/**
 * @author lzw
 * @date 2022/4/21
 * @description
 */
@Controller
public class ActivityController {
    @Resource
    private UserService userService;
    @Resource
    private ActivityService activityService;
    @Resource
    private ActivityRemarkService activityRemarkService;

    /**
     * 处理市场活动首页的功能
     * @param request
     * @return
     */
    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {
        List<User> userList = userService.queryAllUsers();
        //保存到request域中
        request.setAttribute("userList",userList);
        //跳转
        return "workbench/activity/index";
    }

    /**
     * 处理创建市场活动的功能
     * @param activity
     * @param session
     * @return
     */
    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));
        activity.setCreateBy(user.getId());

        ReturnObject returnObject = new ReturnObject();

        try {
            //调用service
            int result = activityService.saveCreateActivity(activity);

            if (result > 0) { //插入成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else { //插入失败
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
     * 根据查询条件，从数据库查找市场活动，并进行分页
     * @param name
     * @param owner
     * @param startDate
     * @param endDate
     * @param pageNo 当前页码
     * @param pageSize 每页显示条数
     * @return
     */
    @RequestMapping("/workbench/acticity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name,String owner,String startDate,String endDate,
                                                  int pageNo,int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);

        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryActivityOfCountByCondition(map);

        //根据查询结果，生成响应信息
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("activityList",activityList);
        retMap.put("totalRows",totalRows);

        return retMap;
    }

    /**
     * 处理批量删除市场活动的功能
     * @param id
     * @return
     */
    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    @ResponseBody
    public Object deleteActivityByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service,删除市场活动以及其市场活动备注
            activityService.deleteActivityByIds(id);

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
     * 根据id获需要修改的市场活动的所有信息，用于修改页面信息回显
     * @param id
     * @return
     */
    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id) {
        //调用service
        Activity activity = activityService.queryActivityById(id);
        //返回响应信息
        return activity;
    }

    /**
     * 保存修改后的市场活动
     * @param activity
     * @param session
     * @return
     */
    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(Activity activity,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        activity.setEditTime(DateUtils.formatDateTime(new Date()));
        activity.setEditBy(user.getId());

        ReturnObject returnObject = new ReturnObject();
        try {
            //调用service
            int result = activityService.saveEditActivity(activity);
            //根据结果，生成响应信息
            if (result > 0) {//成功
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
     * 处理批量导出功能
     * @param response
     * @throws Exception
     */
    @RequestMapping("/workbench/activity/exportAllActivities.do")
    public void exportAllActivities(HttpServletResponse response) throws Exception {
        //调用service
        List<Activity> activityList = activityService.queryAllActivities();

        //创建Excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        //表头信息
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        if (activityList != null && activityList.size() > 0) {
            Activity activity = null;
            //循环写入数据
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i);

                row = sheet.createRow(i + 1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }

        /*//在服务器磁盘上生成Excel文件,效率低,不推荐
        OutputStream os = new FileOutputStream("D:\\activityList.xls");
        wb.write(os);
        os.flush();
        //关闭资源
        os.close();
        wb.close();*/

        //下载Excel文件
        //设置响应类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //设置响应头，使浏览器接收到响应的信息之后，直接激活下载窗口，即使能打开也不打开，如果不设置，浏览器会调用电脑应用程序打开Excel文件，而不进行下载
        response.addHeader("Content-Disposition","attachment;filename=activityList.xls");

        //从浏览器获取输出流
        OutputStream out = response.getOutputStream();

        /*//读取excel文件，将数据输出到浏览器，从磁盘读到浏览器效率低，不推荐
        InputStream is = new FileInputStream("D:\\activityList.xls");
        byte[] buff = new byte[256];
        int len = 0;
        while ((len = is.read(buff)) != -1) {
            out.write(buff,0,len);
        }
        //关闭资源
        is.close();*/

        //直接从wb中读数据到浏览器
        wb.write(out);
        wb.close();
        out.flush();
    }

    /**
     * 处理选择导出功能
     * @param id 勾选的市场活动的id
     * @param response
     * @throws Exception
     */
    @RequestMapping("/workbench/activity/exportSelectiveActivity.do")
    public void exportSelectiveActivity(String[] id,HttpServletResponse response) throws Exception {
        //调用service
        List<Activity> activityList = activityService.queryActivityByIdsForExport(id);

        //创建Excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        //表头信息
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        if (activityList != null && activityList.size() > 0) {
            Activity activity = null;
            //循环写入数据
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i);

                row = sheet.createRow(i + 1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }
        //下载Excel文件
        //设置响应类型，二进制数据流
        response.setContentType("application/octet-stream;charset=UTF-8");
        //设置响应头，使浏览器接收到响应的信息之后，直接激活下载窗口，即使能打开也不打开，如果不设置，浏览器会调用电脑应用程序打开Excel文件，而不进行下载
        response.addHeader("Content-Disposition","attachment;filename=activityList.xls");

        //从浏览器获取输出流
        OutputStream out = response.getOutputStream();

        //直接从wb中读数据到浏览器
        wb.write(out);
        wb.close();
        out.flush();
    }

    /**
     * 处理导入数据的功能
     * @param activityFile
     * @return
     */
    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile,HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        try {
            /*//把文件写入到服务器磁盘，效率低
            String originalFilename = activityFile.getOriginalFilename();
            File file = new File("D:\\"+originalFilename);
            activityFile.transferTo(file);
            //解析excel数据,获取文件中的数据
            InputStream is = new FileInputStream("D:\\"+originalFilename);*/

            //下面这种效率高
            InputStream is = activityFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            HSSFSheet sheet = wb.getSheetAt(0);
            HSSFRow row = null;
            HSSFCell cell = null;
            Activity activity = null;

            List<Activity> activityList = new ArrayList<>();
            for (int i = 1; i <= sheet.getLastRowNum(); i++) { //getLastRowNum()：最后一行
                row = sheet.getRow(i);

                activity = new Activity();
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());

                for (int j = 0; j < row.getLastCellNum(); j++) {//getLastCellNum()：最后一列+1
                    cell = row.getCell(j);
                    //获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);

                    if (j == 0) {
                        activity.setName(cellValue);
                    }else if (j == 1) {
                        activity.setStartDate(cellValue);
                    }else if(j == 2) {
                        activity.setEndDate(cellValue);
                    }else if (j == 3) {
                        activity.setCost(cellValue);
                    }else {
                        activity.setDescription(cellValue);
                    }
                }
                //每一行中所有的列封装好后，添加到activityList
                activityList.add(activity);
            }

            //保存数据到数据库
            int result = activityService.saveCreateActivityByList(activityList);

            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("成功导入" + result + "条数据！");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 处理市场活动的详细信息
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id,HttpServletRequest request) {
        //查询数据
        Activity activity = activityService.queryActivityByIdForDetail(id);
        List<ActivityRemark> remarkList = activityRemarkService.queryActivityRemarkByActivityIdForDetail(id);
        //保存到requet
        request.setAttribute("activity",activity);
        request.setAttribute("remarkList",remarkList);
        //请求转发
        return "workbench/activity/detail";
    }
}
