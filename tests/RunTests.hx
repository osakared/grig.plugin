package;
  
import tink.testrunner.*;
import tink.unit.*;

class RunTests
{

    static function main()
    {
        Runner.run(TestBatch.make([
            new LV2Test(),
        ])).handle(Runner.exit);
    }

}
