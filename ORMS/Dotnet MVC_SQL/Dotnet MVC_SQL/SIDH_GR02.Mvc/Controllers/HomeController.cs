using Microsoft.AspNetCore.Mvc;

namespace SIDH_GR02.Mvc.Controllers;

public class HomeController : Controller
{
    [HttpGet("")]
    public IActionResult Index() => View();
}
