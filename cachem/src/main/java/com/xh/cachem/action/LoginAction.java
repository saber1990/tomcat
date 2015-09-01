package com.xh.cachem.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.xh.cachem.bean.User;

@Controller
public class LoginAction{

    @RequestMapping(value = "/login.do")
    public String loginForm(User user, Model model, HttpServletRequest request, HttpServletResponse response) {
    	if(user.getUsername() == null || user.getPassword() == null){
    		model.addAttribute("msg","");
    		return "login"; 
    	}
    	if(!"xinhua".equals(user.getUsername()) || !"xinhua".equals(user.getPassword())){
    		model.addAttribute("msg","用户或者密码错误!");
    		return "login";    		
    	} 
    	HttpSession session = request.getSession();
		session.setAttribute("user", user);
		return "redirect:/views/index.jsp";
    } 

}
