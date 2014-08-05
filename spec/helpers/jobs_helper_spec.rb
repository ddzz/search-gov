require 'spec_helper'

describe JobsHelper do
  fixtures :affiliates

  describe '#format_salary' do
    it 'should return nil when minimum is nil' do
      job = mock('job', minimum: nil, maximum: nil, rate_interval_code: 'PA')
      helper.format_salary(job).should be_nil
    end

    it 'should return nil when minimum is zero and maximum is nil' do
      job = mock('job', minimum: 0, maximum: nil, rate_interval_code: 'PH')
      helper.format_salary(job).should be_nil
    end

    it 'should return salary when minimum is not zero and maximum is nil' do
      job = mock('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PH')
      helper.format_salary(job).should == '$17.50/hr'
    end

    it 'should return salary when the rate interval is not PA, PH or WC' do
      job = mock('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PD')
      helper.format_salary(job).should == '$17.50 Per Day'
    end

    it 'should return salary range when maximum is not nil and the rate interval is not PA, PH or WC' do
      job = mock('job', minimum: 17.50, maximum: 20.50, rate_interval_code: 'PD')
      helper.format_salary(job).should == '$17.50-$20.50 Per Day'
    end
  end

  describe '#job_application_deadline' do
    it 'should return nil when end date is nil' do
      helper.job_application_deadline(nil).should be_nil
    end
  end

  describe '#legacy_link_to_more_jobs' do
    context 'when rendering federal jobs' do
      it 'should render a link to usajobs.gov' do
        affiliate = mock_model(Affiliate, has_organization_code?: false)
        search = mock('search', affiliate: affiliate, query: 'gov')
        search.stub_chain(:affiliate, :agency).and_return(nil)
        helper.should_receive(:job_link_with_click_tracking).with(
            'More federal job openings on USAJobs.gov',
            'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end
    end

    context 'when rendering federal jobs for a given organization' do
      let(:search) do
        affiliate = affiliates(:usagov_affiliate)
        affiliate.agency = mock_model(Agency, abbreviation: 'GSA', organization_code: 'GS')
        mock('search', affiliate: affiliate, query: 'gov')
      end

      before do
        search.stub_chain(:jobs).and_return([mock('job', id: 'usajobs:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        helper.should_receive(:job_link_with_click_tracking).with(
            'More GSA job openings on USAJobs.gov',
            'https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=GS&PostingChannelID=USASearch&ApplicantEligibility=all',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          helper.should_receive(:job_link_with_click_tracking).with(
              'Más trabajos en GSA en USAJobs.gov',
              'https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=GS&PostingChannelID=USASearch&ApplicantEligibility=all',
              search.affiliate, 'gov', -1, nil)
          helper.legacy_link_to_more_jobs(search)
        end
      end
    end

    context 'when rendering neogov jobs for a given organization' do
      let(:search) do
        affiliate = affiliates(:usagov_affiliate)
        affiliate.agency = mock_model(Agency, name: 'State of Michigan', organization_code: 'USMI')
        mock('search', affiliate: affiliate, query: 'gov')
      end

      before do
        search.stub_chain(:jobs).and_return([mock('job', id: 'ng:michigan:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        helper.should_receive(:job_link_with_click_tracking).with(
            'More State of Michigan job openings',
            'http://agency.governmentjobs.com/michigan/default.cfm',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          helper.should_receive(:job_link_with_click_tracking).with(
              'Más trabajos en State of Michigan',
              'http://agency.governmentjobs.com/michigan/default.cfm',
              search.affiliate, 'gov', -1, nil)
          helper.legacy_link_to_more_jobs(search)
        end
      end
    end
  end
end
