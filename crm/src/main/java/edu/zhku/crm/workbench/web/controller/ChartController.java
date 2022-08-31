package edu.zhku.crm.workbench.web.controller;

import edu.zhku.crm.workbench.domain.ChartVo;
import edu.zhku.crm.workbench.service.TranService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/8
 * @description
 */
@Controller
public class ChartController {

    @Resource
    private TranService tranService;

    /**
     * 跳转到交易统计表页面
     * @return
     */
    @RequestMapping("/workbench/chart/transaction/toTranIndex.do")
    public String toTranIndex() {
        return "workbench/chart/transaction/index";
    }

    /**
     * 查询交易中各个阶段的数据量，用于绘图
     * @return
     */
    @RequestMapping("/workbench/chart/transaction/queryCountOfTranGroupByStage.do")
    @ResponseBody
    public Object queryCountOfTranGroupByStage() {
        //调用service，查询数据
        List<ChartVo> chartVoList = tranService.queryCountOfTranGroupByStage();
        //返回
        return chartVoList;
    }

}
